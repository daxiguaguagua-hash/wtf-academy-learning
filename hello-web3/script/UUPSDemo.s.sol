// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {UUPSProxyDemo} from "../src/UUPSProxyDemo.sol";
import {UUPSLogicV1} from "../src/UUPSLogicV1.sol";
import {UUPSLogicV2} from "../src/UUPSLogicV2.sol";

contract UUPSDemoScript is Script {
    address public constant USER = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.addr(privateKey);

        vm.startBroadcast(privateKey);

        UUPSLogicV1 logicV1 = new UUPSLogicV1();
        UUPSLogicV2 logicV2 = new UUPSLogicV2();

        bytes memory initData = abi.encodeWithSignature(
            "initialize(address,uint256)",
            USER,
            100
        );

        UUPSProxyDemo proxy = new UUPSProxyDemo(address(logicV1), initData);

        vm.stopBroadcast();

        console2.log("UUPS logicV1:", address(logicV1));
        console2.log("UUPS logicV2:", address(logicV2));
        console2.log("UUPS proxy:", address(proxy));
        console2.log("UUPS deployer:", admin);
        console2.log("UUPS user:", USER);
    }
}
