//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployScript} from "script/DeployScript.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;
    uint256 public entranceFee;
    uint256 public interval;
    address PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    /**Events */
    event RaffleEntered(address indexed player);
    event PickedWinner(address indexed winner);

    function setUp() external {
        DeployScript deployer = new DeployScript();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testCheckInitializedRaffleStateIsOpen() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testCheckRaffleStateUint() public view {
        assert(uint256(raffle.getRaffleState()) == 0);
    }

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
}
