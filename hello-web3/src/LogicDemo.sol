// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract LogicDemo {
    uint256 public number;
    address public sender;
    uint256 public value;

    function setVars(uint256 newNumber) external payable {
        number = newNumber;
        sender = msg.sender;
        value = msg.value;
    }
}
