//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract Raffle {
    uint256 private immutable i_enteranceFee;

    constructor(uint256 _enteranceFee) {
        i_enteranceFee = _enteranceFee;
    }

    function enterRaffle() public payable {}

    function pickWinner() public {}
}
