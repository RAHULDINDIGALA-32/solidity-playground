// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 

contract StakingContract is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ===== TYPE DECLARATIONS =====
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 unlockTime;
    }

    // ===== STATE VARIABLES =====
    IERC20 public immutable i_stakingToken;
    IERC20 public immutable i_rewardToken;

    uint256 public s_rewardRate; // tokens per second
    uint256 public s_lastUpdateTimestamp;
    uint256 public s_accRewardPerShare;
    uint256 public constant PRECISION = 1e18;

    uint256 public s_totalStaked;
    uint256 public s_lockDuration;

    mapping(address user => UserInfo) public users;

    // ===== EVENTS =====
    

    // ===== ERRORS =====
    error StakingContract__ZeroAmount();
    error StakingContract__AmountMustBeGreaterThanZero();

    // ===== MODIFIERS =====

    // ===== FUNCTIONS =====

    // ===== Constructor =====
    constructor(
        IERC20 _stakingToken,
        IERC20 _rewardToken,
        uint256 _rewardRate,
        uint256 _lockDuration
    ) {
        i_stakingToken = _stakingToken;
        i_rewardToken = _rewardToken;
        s_rewardRate = _rewardRate;
        s_lockDuration = _lockDuration;
        
        s_lastUpdateTimestamp = block.timestamp;
    }
     
    // ===== External Functions =====
    function stake(uint256 amount) external nonReentrant {
        if (amount == 0) {
            revert StakingContract__AmountMustBeGreaterThanZero();
        }

        _updatePool();
        UserInfo storage user = users[msg.sender];

        if(user.amount > 0) {
            uint256 pendingReward = (user.amount * accRewardPerShare) / PRECISION - user.rewardDebt;
            i_rewardToken.safeTransfer(msg.sender, pendingReward);
        }

        i_stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        user.amount += amount;
        user.unlockTime = block.timestamp + s_lockDuration;
        user.rewardDebt = (user.amount * accRewardPerShare) / PRECISION;

        s_totalStaked += amount;
    }

    function claim() external nonReentrant {
        updatePool();
        USerInfo storage user = users[msg.sender];

        uint256 PendingReward = (user.amount * accRewardPerShare) / PRECISION - user.rewardDebt;

        if(pending == 0) {
            revert StakingContract__ZeroAmount();
        }

        i_rewardToken.safeTransfer(msg.sender, pendingReward);
        user.rewardDebt = (user.amount * accRewardPerShare) / PRECISION;
    }

    function withdraw(uint256 _amount) external nonReentrant {
        UserInfo storage user = users[msg.sender];
        if(block.timestamp < user.unlockTime) {
            revert StakingContract__WithdrawTooEarly();
        }
        if(_amount > user.amount) {
            revert StakingContract__WithdrawTooMuch();
        }

        _updatePool();

        uint256 pendingReward = (user.amount * s_accRewardPerShare) / PRECISION - user.rewardDebt;

        i_rewardToken.safeTransfer(msg.sender, pendingReward);
        i_stakingToken.safeTransfer(msg.sender, _amount);
        user.amount -= _amount;
        user.rewardDebt = (user.amount * s_accRewardPerShare) / PRECISION;

        s_totalStaked -= _amount;
    }

    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = users[msg.sender];
        stakingToken.safeTransfer(msg.sender, user.amount);

        s_totalStaked -= user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // ===== Internal Functions =====
    function _updatePool() internal {
        if(block.timestamp > s_lastUpdateTimestamp && s_totalStaked > 0) {
            uint256 time = block.timestamp - s_lastUpdateTimestamp;
            uint256 rewards = time * s_rewardRate;
            s_accRewardPerShare += (rewards * PRECISION) / s_totalStaked;
        }
        s_lastUpdateTimestamp = block.timestamp;
    }
}