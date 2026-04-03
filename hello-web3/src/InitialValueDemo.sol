// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract InitialValueDemo {
    bool public flag;
    uint256 public amount;
    int256 public score;
    address public owner;
    string public name;
    mapping(address => uint256) public balances;

    uint256[] public numbers;

    struct Person {
        string name;
        uint256 age;
    }

    Person public person;

    function setAmount(uint256 newAmount) public {
        amount = newAmount;
    }

    function resetAmount() public {
        delete amount;
    }

    function resetAll() public {
        delete flag;
        delete amount;
        delete score;
        delete owner;
        delete name;
        // delete balances; // 这个会报错，实际上使用 delete balances[key] 来重置某个地址的余额
        delete numbers;
        delete person;
    }
}
