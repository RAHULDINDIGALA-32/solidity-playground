// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title A simple Raffle Contract
 * @author Rahul Dindigala
 * @notice This contract is for creating a simple raffle system where users can enter by paying an entrance fee.
 * @dev This contract uses Chainlink VRF for randomness and Chainlink Keepers for automated winner selection.
 */

contract Raffle {
    /* Custom Errors */
    error Raffle__SendMoreEthToEnterRaffle();

    uint256 private immutable i_entranceFee;
    /* @dev The duration of the lottery in seconds */
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    /** Events */
    event RaffleEntered(address indexed player);

    constructor(uint256 _entranceFee, uint256 _interval) {
        i_entranceFee = _entranceFee;
        i_interval = _interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        // require(msg.value >= i_entranceFee, NotEnoughEth())
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreEthToEnterRaffle();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external {
        // check to see if enough time has passed
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }
    }

    /** Getter Functions */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}
