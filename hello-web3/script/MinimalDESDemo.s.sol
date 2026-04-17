// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {MinimalDESDemo} from "../src/MinimalDESDemo.sol";

contract MinimalDESDemoScript is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        MinimalDESDemo demo = new MinimalDESDemo();

        vm.stopBroadcast();

        console2.log("demo:", address(demo));
    }
}
