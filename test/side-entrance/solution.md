A surprisingly simple pool allows anyone to deposit ETH, and withdraw it at any point in time.

It has 1000 ETH in balance already, and is offering free flash loans using the deposited ETH to promote their system.

Starting with 1 ETH in balance, pass the challenge by taking all ETH from the pool.

-----

The issue here is the pool flashloan is relying on his balance to revert.
We can exploit this because there is a deposit function that will increase the balance of the pool.
So in the flashloan execution we can deposit the amount borrowed so the flashloan won't revert and the withdraw the amount deposited.

contracts/side-entrance/SideEntranceAttacker.sol
