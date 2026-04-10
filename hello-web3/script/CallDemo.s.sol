// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {CallTargetDemo} from "../src/CallTargetDemo.sol";
import {CallDemo} from "../src/CallDemo.sol";

contract CallDemoScript is Script {
    // 被低级 call 的目标合约
    CallTargetDemo public callTargetDemo;
    // 发起低级 call 的调用方合约
    CallDemo public callDemo;

    function setUp() public {}

    function run() public {
        // startBroadcast 之后，下面的 new 才会真的发链上部署交易
        vm.startBroadcast();

        // 先部署目标合约，后面会把它的地址作为参数传给 CallDemo
        callTargetDemo = new CallTargetDemo();
        // 这里只部署调用方本身，不在构造函数里绑定目标地址
        // 因为这一章想强调：call 的目标地址可以在真正调用时再传入
        callDemo = new CallDemo();

        vm.stopBroadcast();
    }
}
