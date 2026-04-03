// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ControlFlowDemo {
    function checkNumber(uint256 x) public pure returns (string memory) {
        if (x > 10) {
            return "big";
        } else {
            return "small";
        }
    }

    /**
     * @notice 链上布置循环判断，需要特别小心。除了边界条件，还要特别注意 gas 成本。
     */
    function sum(uint256 n) public pure returns (uint256 total) {
        for (uint256 i = 1; i <= n; i++) {
            total += i;
        }
    }
}
