To incentivize the creation of more secure wallets in their team, someone has deployed a registry of Gnosis Safe wallets. When someone in the team deploys and registers a wallet, they will earn 10 DVT tokens.

To make sure everything is safe and sound, the registry tightly integrates with the legitimate Gnosis Safe Proxy Factory, and has some additional safety checks.

Currently there are four people registered as beneficiaries: Alice, Bob, Charlie and David. The registry has 40 DVT tokens in balance to be distributed among them.

Your goal is to take all funds from the registry. In a single transaction.
-----------------------

We notice the proxyCreated method is doing the payment for newly created token to the proxy
```solidity
File: contracts/backdoor/WalletRegistry.sol
/**
     * @notice Function executed when user creates a Gnosis Safe wallet via GnosisSafeProxyFactory::createProxyWithCallback
     *          setting the registry's address as the callback.
     */
69:     function proxyCreated(

126:         // Pay tokens to the newly created wallet
127:         SafeTransferLib.safeTransfer(
128:             address(token),
129:             walletAddress,
130:             PAYMENT_AMOUNT
131:         );
```

And is called when `GnosisSafeProxyFactory::createProxyWithCallback` is called.

Also we noticed some checks done in `proxyCreated` are related to the parameter we have to pass to the `GnosisSafeProxyFactory::createProxyWithCallback`.
More interesting one is:
```solidity
// Ensure initial calldata was a call to `GnosisSafe::setup`
        if (bytes4(initializer[:4]) != GnosisSafe.setup.selector) {
            revert InvalidInitialization();
```

Looking at GnosisSafe::setup we see there are two interesting parameters related to delegate calls:
```
/// @dev Setup function sets initial storage of contract.
    /// @param _owners List of Safe owners.
    /// @param _threshold Number of required confirmations for a Safe transaction.
    /// @param to Contract address for optional delegate call.
    /// @param data Data payload for optional delegate call.
    /// @param fallbackHandler Handler for fallback calls to this contract
    /// @param paymentToken Token that should be used for the payment (0 is ETH)
    /// @param payment Value that should be paid
    /// @param paymentReceiver Adddress that should receive the payment (or 0 if tx.origin)
    function setup(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) external {
        // setupOwners checks if the Threshold is already set, therefore preventing that this method is called twice
        setupOwners(_owners, _threshold);
        if (fallbackHandler != address(0)) internalSetFallbackHandler(fallbackHandler);
        // As setupOwners can only be called if the contract has not been initialized we don't need a check for setupModules
        setupModules(to, data);
```

So when we call GnosisSafeProxyFactory.createProxyWithCallback(), we can have the newly created GnosisSafeProxy during its setup() delegatecall to an arbitrary function with arbitrary parameters we control.

So our function will be called in the context of the newly created GnosisSafeProxy. 
This will call approve() on the token contract to approve our attacker contract as a spender.  

The callback `proxyCreated` will transfer the tokens to the proxy.
And as we allowed our attacker contract to spend the tokens in behals of the proxy, we can transfer them to the player.

`contracts/backdoor/BackdoorAttacker.sol`
