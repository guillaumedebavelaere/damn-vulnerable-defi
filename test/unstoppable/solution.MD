There’s a tokenized vault with a million DVT tokens deposited. It’s offering flash loans for free, until the grace period ends.

To pass the challenge, make the vault stop offering flash loans.

You start with 10 DVT tokens in balance.

-----
The goal is to break the executeFlashLoan method.

Looking into this method, which leads to flashLoan method, we notice these lines:

```solidity
File: CTF/damn-vulnerable-defi/contracts/unstoppable/UnstoppableVault.sol
95:         uint256 balanceBefore = totalAssets();
96:         if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance(); // enforce ERC4626 requirement
```
the balanceBefore can be easily modified, because totalAssets() is:
```solidity
asset.balanceOf(address(this));
```

Meaning, if we sent an amount of asset token to the vault contract, with a simple transfer, not using the deposit method, no vault token would be minted, so the check
`convertToShares(totalSupply) != balanceBefore` wont't be valid and the transaction reverts.

