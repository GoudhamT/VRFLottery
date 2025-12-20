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

/**
 * @title A sample Raffle Contract
 * @author Goudham
 * @notice This contract is for creating a sample raffle contract
 * @dev This implements the Chainlink VRF Version 2
 */

/**Errors */
error Raffle__SendMoreETHtoEnter();

contract Raffle {
    uint256 private immutable i_enteranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_player;
    uint256 private s_startedTime;

    /**Events */
    event RaffleEntered(address indexed player);

    constructor(uint256 _enteranceFee, uint256 _interval) {
        i_enteranceFee = _enteranceFee;
        i_interval = _interval;
        s_startedTime = block.timestamp;
    }

    function enterRaffle() external payable {
        // require(msg.value > i_enteranceFee, "Not enough ETH sent");
        // require(msg.value > i_enteranceFee, Raffle__SendMoreETHtoEnter());
        if (msg.value < i_enteranceFee) {
            revert Raffle__SendMoreETHtoEnter();
        }
        s_player.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external view {
        if ((block.timestamp - s_startedTime) < i_interval) {
            revert();
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
}
