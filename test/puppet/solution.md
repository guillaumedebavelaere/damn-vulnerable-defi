There’s a lending pool where users can borrow Damn Valuable Tokens (DVTs). 
To do so, they first need to deposit twice the borrow amount in ETH as collateral. 
The pool currently has 100000 DVTs in liquidity.

There’s a DVT market opened in an old Uniswap v1 exchange, currently with 10 ETH and 10 DVT in liquidity.

Pass the challenge by taking all tokens from the lending pool. You start with 25 ETH and 1000 DVTs in balance.


------

The puppet pool calculates the requried deposit with:

function calculateDepositRequired(uint256 amount) public view returns (uint256) {
        return amount * _computeOraclePrice() * DEPOSIT_FACTOR / 10 ** 18;
    }

function _computeOraclePrice() private view returns (uint256) {
    // calculates the price of the token in wei according to Uniswap pair
    return uniswapPair.balance * (10 ** 18) / token.balanceOf(uniswapPair);
}

We can see we can manipulate the oracle price by providing a large amount of DVT token, so it would be close to zero.
Consequently we can then borrow at a small price all the liquidity of the pool.

To realize this in one transaction we use the EIP 2612 to use the signature to permit + transfer the DVT tokens in one transaction during deploy.

contracts/puppet/PuppetAttacker.sol
