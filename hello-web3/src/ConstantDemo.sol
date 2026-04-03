// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ConstantDemo {
    // 常量
    uint256 public constant MY_NUMBER = 123;

    // 不可变变量
    address public immutable OWNER;

    constructor() {
        OWNER = msg.sender; // 在构造函数中设置不可变变量
    }

    function tryChange() public {
        // MY_NUMBER = 456;
        // OWNER = msg.sender;
    }
}
