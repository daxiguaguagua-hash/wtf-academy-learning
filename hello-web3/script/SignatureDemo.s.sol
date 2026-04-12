// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {SignatureDemo} from "../src/SignatureDemo.sol";

contract SignatureDemoScript is Script {
    SignatureDemo public demo;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        demo = new SignatureDemo();

        vm.stopBroadcast();
    }
}
