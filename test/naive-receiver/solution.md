There’s a pool with 1000 ETH in balance, offering flash loans. It has a fixed fee of 1 ETH.

A user has deployed a contract with 10 ETH in balance. It’s capable of interacting with the pool and receiving flash loans of ETH.

Take all ETH out of the user’s contract. If possible, in a single transaction.

----


The issue here is there is no restriction access on who can called the flashLoan method.

```
File: contracts/naive-receiver/NaiveReceiverLenderPool.sol
37:     function flashLoan(
38:         IERC3156FlashBorrower receiver,
39:         address token,
40:         uint256 amount,
41:         bytes calldata data
42:     ) external returns (bool) {
```

Consequently as an attacker, repeating the flashloan will take out the funds of the receiver to the pool because of a fixed fee taken each time.

```solidity
File: contracts/naive-receiver/FlashLoanReceiver.sol
41:         uint256 amountToBeRepaid;
42:         unchecked {
43:             amountToBeRepaid = amount + fee;
44:         }
45: 
46:         _executeActionDuringFlashLoan();
47: 
48:         // Return funds to pool
49:         SafeTransferLib.safeTransferETH(pool, amountToBeRepaid);
```