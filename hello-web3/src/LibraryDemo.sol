// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import {MathLibrary, StringLibrary} from "./MathLibrary.sol"; // 最好是这样写
// import "./MathLibrary.sol" as MathLib; // 也可以用 as 来给库取个别名，使用时就要 MathLib.max() 了。
import "./MathLibrary.sol"; // 也可以这样写
import {ICounter} from "./InterfaceDemo.sol"; // 也可以这样写

// import contract 只是把“合约类型”引进来；真正使用它，还要通过继承、实例化或者地址绑定。`
import "./Counter.sol"; // 也可以这样写

contract LibraryDemo is ICounter {
    function getNumber() external pure returns (uint256) {
        return 42;
    }

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
