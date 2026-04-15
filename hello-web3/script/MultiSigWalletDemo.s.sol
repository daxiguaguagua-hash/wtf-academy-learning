// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {MultiSigWalletDemo} from "../src/MultiSigWalletDemo.sol";

contract MultiSigWalletDemoScript is Script {
    function run() public {
        // 这里如果使用uint128，不一定更省gas。，他们只有在特定存储打包场景下才更有价值。
        // 256位，32字节
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        // uint 就是 uint256 的别名。EVM的基本处理单位就是 256 bit
        uint requiredCount = 2;

        vm.startBroadcast(privateKey);

        address[] memory owners = new address[](3);
        owners[0] = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        owners[1] = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        owners[2] = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

        MultiSigWalletDemo wallet = new MultiSigWalletDemo(
            owners,
            requiredCount
        );

        vm.stopBroadcast();

        console2.log("wallet:", address(wallet));
        console2.log("owner1:", owners[0]);
        console2.log("owner2:", owners[1]);
        console2.log("owner3:", owners[2]);
        console2.log("required:", requiredCount);
    }
}
