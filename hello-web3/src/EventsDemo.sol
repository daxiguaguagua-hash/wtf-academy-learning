// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EventsDemo {
    // 链上当前状态：现在 number 是多少
    uint256 public number;

    /**
     * @notice 事件是给链下世界看的结构化日志
     * @notice 这条事件会出现在交易回执的 logs 里
     * @notice logs 里最常先看这三部分：
     * 1. address: 是哪个合约发出的事件
     * 2. topics: 事件签名等索引信息，用来区分事件类型
     * 3. data: 事件参数的编码结果，这里会包含 caller 和 newNumber
     */
    event NumberChanged(address caller, uint256 newNumber);

    // 修改状态变量，并额外发出一条事件日志告诉链下“刚刚发生了什么”
    function setNumber(uint256 newNumber) public {
        number = newNumber;
        emit NumberChanged(msg.sender, newNumber);
    }
}
