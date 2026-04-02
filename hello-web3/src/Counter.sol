// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}

contract HelloWeb3 {
    string public _string = "Hello Web3!";
}

contract ValueTypes {
    bool public isActive = true;
    uint256 public age = 18;
    int256 public score = -1;
    // 专门表示20字节以太坊地址的内建类型
    address public owner = 0x1234567890123456789012345678901234567890;
}

contract FunctionDemo {
    // 初始值就是0
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function addOne() public {
        number = number + 1;
    }
}
