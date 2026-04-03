// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ICounter {
    // external 这个主要是给外部调用的，用external来修饰。
    function getNumber() external view returns (uint256);
}

contract Counter is ICounter {
    uint256 public number = 123;

    function getNumber() external view returns (uint256) {
        return number;
    }
}
