There’s a pool offering rewards in tokens every 5 days for those who deposit their DVT tokens into it.

Alice, Bob, Charlie and David have already deposited some DVT tokens, and have won their rewards!

You don’t have any DVT tokens. But in the upcoming round, you must claim most rewards for yourself.

By the way, rumours say a new pool has just launched. Isn’t it offering flash loans of DVT tokens?

-----------

The attack has to be just after the new reward round and before the other users call distribute rewards.
Ideed, thanks to the flashloan we are able to deposit a large sum of money into the reward pool.
It will trigger the distribute reward function and mint the rewards. We will get the majority of the rewards because of the large amount we deposited and the integer division results in all other accounts receiving 0 rewards.

As a general rule, if some logic relies on a single snapshot in time instead of continuous/aggregated data points, it can be manipulated by flash loans
