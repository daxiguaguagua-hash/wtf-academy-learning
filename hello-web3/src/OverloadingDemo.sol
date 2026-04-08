// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @notice 在 Solidity 里，重载只看函数名 + 输入参数列表，不看返回值。
 */
contract OverloadingDemo {
    // 一个参数版本：直接返回自己。
    function sum(uint256 a) public pure returns (uint256) {
        return a;
    }

    // 两个参数版本：返回两数之和。
    function sum(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }

    // 字符串版本：只是原样返回，用来说明重载看参数，不看返回值。
    function sum(string memory text) public pure returns (string memory) {
        return text;
    }
}
