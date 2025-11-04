// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title A simple Raffle Contract
 * @author Rahul Dindigala
 * @notice This contract is for creating a simple raffle system where users can enter by paying an entrance fee.
 * @dev This contract uses Chainlink VRF for randomness and Chainlink Keepers for automated winner selection.
 */

contract Raffle {
    uint256 private immutable i_entranceFee;

    constructor(uint256 _entranceFee) {
        i_entranceFee = _entranceFee;
    }

    function enterRaffle() public payable {}

    function pickWinner() public {}

    /** Getter Functions */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}
