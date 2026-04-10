// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract DelegatecallDemo {
    // 这三个的命名和顺序，必须和LogicDemo里的一模一样
    // 这三个是slot。在Solidity中，状态变量按照声明的顺序存储在连续的存储槽（storage slots）中。
    // 每个状态变量占用一个存储槽，除非它们是紧凑的类型，可以共享一个存储槽。
    uint256 public number;
    address public sender;
    uint256 public value;

    bool public lastSuccess;
    bytes public lastReturnData;

    function delegateSetVars(
        address logicAddress,
        uint256 newNumber
    ) external payable {
        // delegate 修改自己的状态
        (bool success, bytes memory returnData) = logicAddress.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", newNumber)
        );

        lastSuccess = success;
        lastReturnData = returnData;
    }
}
