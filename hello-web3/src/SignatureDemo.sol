// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SignatureDemo {
    // 压缩成固定长度hash
    function getMessageHash(
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_to, _amount, _message, _nonce));
    }

    // 以太坊签名的格式
    function getEthSignedMessageHash(
        bytes32 _messageHash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32", // 这里表示这是一条普通的以太坊签名信息
                    _messageHash
                )
            );
    }

    // 从签名里反推出签名者的地址
    // memory 基本上都使用来修饰引用类型(string/bytes/数组)和struct，函数执行完就释放。
    // 如果是 external ，那么就使用calldata，这样比较省gas。
    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    // 分割签名
    function splitSignature(
        bytes memory signature
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        // 标准 ECDSA 签名固定是 65 字节：32(r) + 32(s) + 1(v)
        require(signature.length == 65, "invalid signature length");
        assembly {
            // bytes memory 在内存里的前 32 字节存的是长度，
            // 真正的签名内容从 signature + 32 开始。
            // 所以这里跳过长度字段，先读出前 32 字节作为 r。
            r := mload(add(signature, 32))

            // 再往后移动 32 字节，读出第二段 32 字节作为 s。
            s := mload(add(signature, 64))

            // 再往后移动 32 字节，来到最后一段。
            // v 只有 1 个字节，所以先整段读 32 字节，
            // 再取这一段的第 1 个字节作为 v。
            v := byte(0, mload(add(signature, 96)))
        }
    }
}
