// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CallTargetDemo {
    uint256 public number;
    uint256 public value;
    string public lastMessage;

    function setNumber(uint256 newNumber) external payable returns (uint256) {
        number = newNumber;
        value = msg.value;
        lastMessage = "setNumber was called";
        return number;
    }
}
