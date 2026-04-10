// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CallDemo {
    // 记录最近一次低级 call 是否成功
    bool public lastSuccess;
    // 记录目标合约返回的原始 bytes 数据
    bytes public lastReturnData;

    function callSetNumber(
        address targetAddress,
        uint256 newNumber
    ) external payable {
        // call 是低级调用：直接对某个地址发起调用，而不是用强类型语法 target.setNumber(...)
        // value: msg.value 表示把本次交易附带的 ETH 一起转给目标合约
        // abi.encodeWithSignature 会把“函数签名 + 参数”编码成 EVM 能识别的 calldata
        // returnData 是临时接住返回值的 bytes，所以要放在 memory 里
        (bool success, bytes memory returnData) = targetAddress.call{
            value: msg.value
        }(abi.encodeWithSignature("setNumber(uint256)", newNumber));

        // 这两个状态变量只是教学观察窗口，方便后面用 cast call 查看结果
        lastSuccess = success;
        lastReturnData = returnData;
    }
}
