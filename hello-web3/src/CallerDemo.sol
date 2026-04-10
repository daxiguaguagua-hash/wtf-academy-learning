// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {TargetDemo} from "./TargetDemo.sol";

contract CallerDemo {
    TargetDemo public target;

    constructor(address _targetAddress) {
        // 这里的TargetDemo为什么没有使用new?
        // 把地址堪称 TargetDemo类型，方便后续调用
        // 表示这个地址上有一个TargetDemo合约，我们要和它进行交互
        target = TargetDemo(_targetAddress);
    }

    // external 强调给外部调用的
    function callSetNumber(uint256 _number) external {
        target.setNumber(_number);
    }

    function callGetNumber() external view returns (uint256) {
        return target.number();
    }
}
