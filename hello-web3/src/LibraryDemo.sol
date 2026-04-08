// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {MathLibrary, StringLibrary} from "./MathLibrary.sol";
// import "./MathLibrary.sol" as MathLib; // 也可以用 as 来给库取个别名，使用时就要 MathLib.max() 了。

contract LibraryDemo {
    function getMax(uint256 a, uint256 b) public pure returns (uint256) {
        return MathLibrary.max(a, b);
    }

    function getMin(uint256 a, uint256 b) public pure returns (uint256) {
        return MathLibrary.min(a, b);
    }

    function toUpperCase(
        string memory str
    ) public pure returns (string memory) {
        return StringLibrary.toUpperCase(str);
    }
}
