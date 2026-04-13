// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {TransparentLogicV1} from "../src/TransparentLogicV1.sol";
import {TransparentLogicV2} from "../src/TransparentLogicV2.sol";
import {TransparentProxyDemo} from "../src/TransparentProxyDemo.sol";

contract TransparentProxyDemoScript is Script {
    // anvil 中的第二个测试账户的账号
    address public constant USER = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        TransparentLogicV1 logicV1 = new TransparentLogicV1();
        TransparentLogicV2 logicV2 = new TransparentLogicV2();

        // 这里为什么要编码？因为EVM只能识别函数选择器 selector，也就是前四个字节
        // 还有参数编码，后面的字节
        // 这里本质上就是：我要调用 initialize(USER, 100) 这个函数，所以要把函数选择器和参数编码成字节数组
        bytes memory initData = abi.encodeWithSignature(
            // 这里的monory通常用于局部的引用变量。
            // 而calldata只能用于外部函数输入参数，用于只读变量。
            "initialize(address,uint256)",
            USER,
            100
        );

        TransparentProxyDemo proxy = new TransparentProxyDemo(
            address(logicV1),
            msg.sender,
            initData
        );

        vm.stopBroadcast();

        console2.log("logicV1:", address(logicV1));
        console2.log("logicV2:", address(logicV2));
        console2.log("proxy:", address(proxy));
        console2.log("admin:", msg.sender);
        console2.log("user:", USER);
    }
}
