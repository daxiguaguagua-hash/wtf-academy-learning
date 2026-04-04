// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ConstructorModifierDemo {
    address public owner;
    uint256 public number;

    constructor() {
        owner = msg.sender;
    }

    // 这是一个鉴权用的modifier，只有合约部署者（owner）才能调用被这个modifier修饰的函数。
    modifier onlyOwner() {
        // require(msg.sender == owner, "Not the owner");
        _onlyOwner();
        _; // 原函数真正开始执行的位置
    }

    // internal 智能合约内部用
    // view 只读函数，不修改状态变量
    // 函数名前面加上“_”，表示这是一个辅助函数，社区内部约定俗成的命名规范
    function _onlyOwner() internal view {
        require(msg.sender == owner, "Not the owner");
    }

    function setNumber(uint256 _number) public onlyOwner {
        number = _number;
    }
}
