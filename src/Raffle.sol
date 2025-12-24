// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A sample Raffle Contract
 * @author Goudham
 * @notice This contract is for creating a sample raffle contract
 * @dev This implements the Chainlink VRF Version 2
 */

/**Errors */
error Raffle__SendMoreETHtoEnter();
error Raffle__TransferFailed();
error Raffle__RaffleisNotOpened();
error Raffle__UpKeepFailed(
    uint256 balance,
    uint256 playerLength,
    uint256 raffleState
);

contract Raffle is VRFConsumerBaseV2Plus {
    /*Type Declarations */
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /* state variables*/
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_enteranceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_gasLimit;
    address payable[] private s_player;
    uint256 private s_startedTime;
    uint256 private s_subscriptionId;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    /**Events */
    event RaffleEntered(address indexed player);
    event PickedWinner(address indexed winner);

    constructor(
        uint256 _enteranceFee,
        uint256 _interval,
        address _vrfCoordinator,
        bytes32 _gasLane,
        uint256 _subscriptionId,
        uint32 _gasLimit
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        i_enteranceFee = _enteranceFee;
        i_interval = _interval;
        s_startedTime = block.timestamp;
        i_gasLane = _gasLane;
        s_subscriptionId = _subscriptionId;
        i_gasLimit = _gasLimit;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        // require(msg.value > i_enteranceFee, "Not enough ETH sent");
        // require(msg.value > i_enteranceFee, Raffle__SendMoreETHtoEnter());
        if (msg.value < i_enteranceFee) {
            revert Raffle__SendMoreETHtoEnter();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleisNotOpened();
        }
        s_player.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    /**
     * @dev - This checkUpKeep function is to validate can contract pick winner?
     * based on below conditions
     * 1.has interval passed?
     * 2.is contract has any balance?
     * 3.is Raffle state is Open?
     * 4.has any player entered raffle?
     * if all condition is passed then winner can be picked
     * @param - ignored
     * @return upkeepNeeded
     * @return
     */
    function checkUpkeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool hasPassed = ((block.timestamp - s_startedTime) > i_interval);
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_player.length > 0;
        upkeepNeeded = hasPassed && isOpen && hasBalance && hasPlayers;
        return (upkeepNeeded, "");
    }

    function performUpkeep(bytes calldata /* performData */) external {
        (bool isRaffleValidtoPick, ) = checkUpkeep("");
        if (!isRaffleValidtoPick) {
            revert Raffle__UpKeepFailed(
                address(this).balance,
                s_player.length,
                uint256(s_raffleState)
            );
        }

        s_raffleState = RaffleState.CALCULATING;
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_gasLane,
                subId: s_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATION,
                callbackGasLimit: i_gasLimit,
                numWords: NUM_WORDS,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

        s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        //checks
        //NA

        uint256 winnerIndex = randomWords[0] % s_player.length;
        address payable pickedWinner = s_player[winnerIndex];
        s_recentWinner = pickedWinner;
        //Effects
        s_raffleState = RaffleState.OPEN;
        s_startedTime = block.timestamp;
        s_player = new address payable[](0);
        emit PickedWinner(s_recentWinner);

        //Interactions
        (bool callSuccess, ) = s_recentWinner.call{
            value: address(this).balance
        }("");
        if (!callSuccess) {
            revert Raffle__TransferFailed();
        }
    }

    /**
     * getter functions
     */
    function getEnteranceFee() external view returns (uint256) {
        return i_enteranceFee;
    }

    function getPlayerByIndex(uint256 _index) external view returns (address) {
        return s_player[_index];
    }

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }
}
