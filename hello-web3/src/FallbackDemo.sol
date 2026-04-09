// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract FallbackDemo {
    // 记录最近一次是从哪个入口进来的
    string public lastEntry;
    address public lastSender;
    uint256 public lastValue;
    bytes public lastData;
    uint256 public totalReceived;

    event Entered(address sender, uint256 value, string entry, bytes data);

    // 正常函数调用：有明确函数名时走这里
    function deposit() external payable {
        totalReceived += msg.value;
        lastEntry = "deposit";
        lastSender = msg.sender;
        lastValue = msg.value;
        lastData = msg.data;

        emit Entered(msg.sender, msg.value, "deposit", msg.data);
    }

    // 只收钱且 calldata 为空时，优先走 receive
    receive() external payable {
        totalReceived += msg.value;
        lastEntry = "receive";
        lastSender = msg.sender;
        lastValue = msg.value;
        lastData = "";

        emit Entered(msg.sender, msg.value, "receive", "");
    }

    // 调不存在的函数，或者带了 calldata 但没匹配上时，走 fallback
    fallback() external payable {
        totalReceived += msg.value;
        lastEntry = "fallback";
        lastSender = msg.sender;
        lastValue = msg.value;
        lastData = msg.data;

        emit Entered(msg.sender, msg.value, "fallback", msg.data);
    }
}
