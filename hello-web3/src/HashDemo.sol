// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @notice 相同数据的哈希值肯定相同。
 */
contract HashDemo {
    bytes32 public hash;

    function hashNumberAndAddress(uint256 number, address addr) external {
        // endoce 负责打包 先把参数编程标准bytes
        // hash 负责摘要 再把bytes压缩成固定长度
        hash = keccak256(abi.encode(number, addr));
    }

    function getHash(
        uint256 number,
        address addr
    ) external pure returns (bytes32) {
        return keccak256(abi.encode(number, addr));
    }
}
