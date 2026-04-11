// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SelectorDemo {
    bytes4 public lastSelector;

    function getSelector() external pure returns (bytes4) {
        return bytes4(keccak256("setNumber(uint256)"));
    }

    function saveSelector() external {
        lastSelector = bytes4(keccak256("setNumber(uint256)"));
    }
}
