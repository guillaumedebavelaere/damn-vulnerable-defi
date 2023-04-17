A new cool lending pool has launched! It’s now offering flash loans of DVT tokens. It even includes a fancy governance mechanism to control it.

What could go wrong, right ?

You start with no DVT tokens in balance, and the pool has 1.5 million. Your goal is to take them all.

-------------------

As the _hasEnoughVotes method of the governance relies on a snapshot, we are able to exploit that
by doing a snapshot during the flashloan.
So we are able to queue an action which will be to call the emergencyExit method to drain the funds.

contracts/selfie/SelfieAttacker.sol
