// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract AbiDemo {
    bytes public encodedData;
    uint256 public decodedNumber;
    address public decodedAddress;

    function encodeData(uint256 number, address addr) external {
        encodedData = abi.encode(number, addr);
    }

    // 内层	abi.encode(123, addr) 的真实编码结果
    // 外层	因为 encodedData() 返回类型是 bytes，ABI 又把这段 bytes 包了一层
    // 所以你后面传给 decodeData(bytes) 的那串，实际上是内层那 64 字节，不是 getter 返回的整串外层包装。
    function decodeData(bytes calldata data) external {
        (uint256 number, address addr) = abi.decode(data, (uint256, address));
        decodedNumber = number;
        decodedAddress = addr;
    }
}
