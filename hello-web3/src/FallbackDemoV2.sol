// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @notice 这里调用的时候带上payable，表示合约是需要有ETH才能运行的，否则就revert了
 * @notice 运行的命令：cast send 合约地址 "deposit()" --value 0.01ether
 */
contract FallbackDemoV2 {
    // 最后一次进入的是哪个入口？
    string public lastEntry;
    address public lastSender;
    // 最后一次调用附带了多少ETH
    uint256 public lastValue;
    // 最后一次调用带了什么数据
    bytes public lastData;
    uint256 public totalReceived;

    event Entered(address sender, uint256 value, string entry, bytes data);

    // 普通函数，需要function关键字修饰
    function deposit() external payable {
        totalReceived += msg.value;
        lastEntry = "deposit";
        lastSender = msg.sender;
        lastValue = msg.value;
        lastData = msg.data;

        emit Entered(msg.sender, msg.value, "deposit", msg.data);
    }

    // 特殊接收ETH入口, 这是solidity固定的
    // 由EVM自动调用，不能直接调用这个函数
    // 只处理 ETH转账，不能带任何数据（calldata必须为空）
    // 空 calldata 收款口
    receive() external payable {
        totalReceived += msg.value;
        lastEntry = "receive";
        lastSender = msg.sender;
        lastValue = msg.value;
        lastData = "";

        emit Entered(msg.sender, msg.value, "receive", "");
    }

    // 特殊兜底入口
    // 当调用一个不存在的函数，或者带了数据但没有匹配的函数时，就会走这里
    // 或者带了eth，但是有calldata，但没有匹配的函数时，也会走这里
    // 有数据但没有匹配上的兜底口
    fallback() external payable {
        totalReceived += msg.value;
        lastEntry = "fallback";
        lastSender = msg.sender;
        lastValue = msg.value;
        lastData = msg.data;

        emit Entered(msg.sender, msg.value, "fallback", msg.data);
    }
}
