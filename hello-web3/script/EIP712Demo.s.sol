// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// 这里的UNLICENSED只是发布脚本使用，不一定要用MIT

import {Script} from "forge-std/Script.sol";
import {EIP712Demo} from "../src/EIP712Demo.sol";

contract EIP712DemoScript is Script {
    EIP712Demo public demo;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        demo = new EIP712Demo();

        vm.stopBroadcast();
    }
}
