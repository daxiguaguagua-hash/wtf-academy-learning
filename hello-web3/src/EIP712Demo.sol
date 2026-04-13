// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * EIP712是在普通签名之前，先把“上下文”和“结构”定义清楚。
 *
 * @notice 这个和ERC20比起来，更加有结构化，并且防止跨链
 * @notice 不是只签内容，而是签“带身份和格式说明的内容”。
 *
 * 代码元素	             它是在解决什么问题
 * domainSeparator	    这份签名属于哪个场景
 * typeHash	            这份数据长什么样
 * structHash	        这次到底签了什么值
 * typedDataHash	    最终把“场景 + 数据”绑死
 */
contract EIP712Demo {
    /**
     * 普通签名上下文不清楚，所以需要加domain
     */
    bytes32 public constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            // 这里的参数之间不能有空格，不然计算的hash会不同的。
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 public constant MAIL_TYPEHASH =
        keccak256(
            "Mail(address to,uint256 amount,string message,uint256 nonce)"
        );

    // 生成当前合约/当前链的 domain
    // 别把A项目的签名拿到B项目去使用
    // 别把这条链的签名拿到另一条链去用
    function getDomainSeparator() public view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    EIP712_DOMAIN_TYPEHASH,
                    keccak256(bytes("WTF Academy")),
                    keccak256(bytes("1")),
                    block.chainid,
                    address(this)
                )
            );
    }

    // 返回结构模版 hash
    // 表示：我签订的是那种结构的数据。不能只说“我签了一段数据”。
    function getTypeHash() public pure returns (bytes32) {
        return MAIL_TYPEHASH;
    }

    // 返回这次数据 hash
    // 为什么需要这个函数？因为模板是 Mail ，需要有具体的数据：_to,_amount,_message,_nonce
    // 把模板和值绑定在一起，才能得到唯一的hash
    function getStructHash(
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    MAIL_TYPEHASH,
                    _to,
                    _amount,
                    keccak256(bytes(_message)),
                    _nonce
                )
            );
    }

    // 组合出最终 EIP712 digest
    // 为什么最后还要这个？因为钱包最终签订的不是单独的domain或者struct，而是
    // 这份domain下的这份struct，所以最终要把它们拼接起来。
    function getTypedDataHash(
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce // 这个是 number used once 的缩写
    ) public view returns (bytes32) {
        bytes32 structHash = getStructHash(_to, _amount, _message, _nonce);

        return
            keccak256(
                abi.encodePacked("\x19\x01", getDomainSeparator(), structHash)
            );
    }

    // 从EIP712最终hash和签名里恢复地址
    function recoverSigner(
        bytes32 _typedDataHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_typedDataHash, v, r, s);
    }

    // 把签名拆分成rsv
    function splitSignature(
        bytes memory _signature
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(_signature.length == 65, "invalid signature length");

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }
    }
}
