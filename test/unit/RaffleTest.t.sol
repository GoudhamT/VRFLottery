//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployScript} from "script/DeployScript.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;
    uint256 public entranceFee;
    uint256 public interval;
    address public vrfCoordinator;
    address PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    /**Events */
    event RaffleEntered(address indexed player);
    event PickedWinner(address indexed winner);
    event RandomNumberGenerated(uint256 indexed requestId);

    function setUp() external {
        DeployScript deployer = new DeployScript();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testCheckInitializedRaffleStateIsOpen() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testCheckRaffleStateUint() public view {
        assert(uint256(raffle.getRaffleState()) == 0);
    }

    /*//////////////////////////////////////////////////////////////
                              ENTER RAFFLE
    //////////////////////////////////////////////////////////////*/

    function testRevertWhileEnterRaffleWithoutMoney() public {
        //arrange
        vm.prank(PLAYER);
        //Act & // assert
        vm.expectRevert(Raffle.Raffle__SendMoreETHtoEnter.selector);
        raffle.enterRaffle();
    }

    function testRaffleCheckPlayerAddress() public {
        //Arrange
        vm.prank(PLAYER);
        //Act
        raffle.enterRaffle{value: entranceFee}();
        address enteredAddress = raffle.getPlayerByIndex(0);
        //Assert
        assert(enteredAddress == PLAYER);
        assert(raffle.getPlayerCount() == 1);
    }

    function testRaffleEnteredEvent() public {
        //arrange
        vm.prank(PLAYER);
        console.log(PLAYER);
        //Act
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);
        //assert
        raffle.enterRaffle{value: entranceFee}();
    }

    function testRaffleErrorWhileCalculating() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");
        //Act / Assert
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__RaffleisNotOpened.selector);
        raffle.enterRaffle{value: entranceFee}();
    }

    /*//////////////////////////////////////////////////////////////
                              CHECK UPKEEP
    //////////////////////////////////////////////////////////////*/

    function testCheckUpKeepNeededFalseForZEROBalance() public {
        //Arrange
        vm.prank(PLAYER);
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        //Act
        (bool upKeepNeeded, ) = raffle.checkUpkeep("");
        //Assert
        assert(!upKeepNeeded);
    }

    modifier raffleEntered() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testCheckUpKeepNeededFailesOPENState() public raffleEntered {
        //Arrange
        raffle.performUpkeep("");
        //Act
        (bool upKeepNeeded, ) = raffle.checkUpkeep("");
        //Assert
        assert(!upKeepNeeded);
    }

    function testUpKeepNeededHasntPassed() public {
        //Arrange
        vm.prank(PLAYER);
        //Act
        (bool checkUpKeep, ) = raffle.checkUpkeep("");
        //Assert
        assert(!checkUpKeep);
    }

    function testCheckUpKeepNeededIsPassed() public raffleEntered {
        //Act
        (bool checkUpKeepNeeded, ) = raffle.checkUpkeep("");
        //Assert
        assert(checkUpKeepNeeded);
    }

    /*//////////////////////////////////////////////////////////////
                              PERFORM UPKEEP
    //////////////////////////////////////////////////////////////*/
    function testPerformUpKeepIsGood() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        //Act / Assert
        raffle.performUpkeep("");
    }

    function testPerformUpKeepFailedWhenCheckUpkeepFails() public {
        //Arrange
        uint256 balance = 0;
        uint256 playerLength = 0;
        Raffle.RaffleState rState = raffle.getRaffleState();
        //Act
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__UpKeepFailed.selector,
                balance,
                playerLength,
                rState
            )
        );
        raffle.performUpkeep("");
    }

    function testPerformUpKeepStateAndEmitRequestID() public raffleEntered {
        //Arrange
        // raffle.performUpkeep("");
        //Act
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        // console.log("Total logs:", entries.length);

        // for (uint256 i = 0; i < entries.length; i++) {
        //     console.log("---- Log index ----", i);
        //     console.log("Emitter:", entries[i].emitter);
        //     console.log("Topics length:", entries[i].topics.length);

        //     for (uint256 j = 0; j < entries[i].topics.length; j++) {
        //         console.logBytes32(entries[i].topics[j]);
        //     }

        //     console.logBytes(entries[i].data);
        // }
        bytes32 requestId = entries[1].topics[1];
        //Assert
        assert(requestId > 0);
        assert(uint256(raffle.getRaffleState()) == 1);
    }

    /*//////////////////////////////////////////////////////////////
                              Fullfill Random Words
    //////////////////////////////////////////////////////////////*/
    function testCallFullFillRandomWordsOnlyAfterPerformUpKeepPasses(
        uint256 _requestId
    ) public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            _requestId,
            address(raffle)
        );
    }

    function testFullfillRandomWordsPickWinnerAndValidate()
        public
        raffleEntered
    {
        //Arrange
        uint256 morePlayers = 3;
        uint256 startingIndex = 1;
        address expectedWinner = address(1);

        for (uint256 i = startingIndex; i < morePlayers + startingIndex; i++) {
            address newPlayer = address(uint160(i));
            // address newPlayer = vm.addr(i);
            hoax(newPlayer, 1 ether);
            raffle.enterRaffle{value: entranceFee}();
        }
        uint256 startingTimeStamp = raffle.getLastTimeStamp();
        uint256 startingBalance = expectedWinner.balance;
        uint256 raffleWinningAmount = entranceFee * (morePlayers + 1);
        //Act
        //get event logs
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId),
            address(raffle)
        );

        //Assert
        uint256 winnersBalance = raffle.getRecentWinner().balance;
        console.log(raffle.getRecentWinner());
        Raffle.RaffleState rState = raffle.getRaffleState();
        uint256 endingTimeStamp = raffle.getLastTimeStamp();
        assert(uint256(rState) == 0);
        assert(winnersBalance > 0);
        assert(winnersBalance == startingBalance + raffleWinningAmount);
        // console.log("winning maount ", winnersBalance);
        assert(endingTimeStamp > startingTimeStamp);
    }
}
