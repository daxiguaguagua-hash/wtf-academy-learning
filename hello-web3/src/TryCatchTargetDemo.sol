// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TryCatchTargetDemo {
    uint256 public number;

    function setNumber(uint256 newNumber) external returns (uint256) {
        require(newNumber > 0, "number must be greater than 0");
        number = newNumber;
        return number;
    }
}
