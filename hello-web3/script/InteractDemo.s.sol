// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {TargetDemo} from "../src/TargetDemo.sol";
import {CallerDemo} from "../src/CallerDemo.sol";

contract InteractDemoScript is Script {
    TargetDemo public targetDemo;
    CallerDemo public callerDemo;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // 先部署TargetDemo
        targetDemo = new TargetDemo();

        // 再部署CallerDemo，构造函数需要TargetDemo的地址
        callerDemo = new CallerDemo(address(targetDemo));

        // 通过CallerDemo调用TargetDemo的函数
        // callerDemo.callSetNumber(42);

        // 通过CallerDemo读取TargetDemo的状态变量
        // uint256 number = callerDemo.callGetNumber();
        // console.log("Number in TargetDemo:", number); // 应该输出42

        vm.stopBroadcast();
    }
}
