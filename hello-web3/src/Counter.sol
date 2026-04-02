// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}

contract HelloWeb3 {
    string public _string = "Hello Web3!";
}

contract ValueTypes {
    bool public isActive = true;
    uint256 public age = 18;
    int256 public score = -1;
    // 专门表示20字节以太坊地址的内建类型
    address public owner = 0x1234567890123456789012345678901234567890;
}

contract FunctionDemo {
    // 初始值就是0
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function addOne() public {
        number = number + 1;
    }
}

/**
 * @title FunctionOutputs
 * @dev A contract demonstrating function outputs
 * @notice 这里的pure表示，不读取也不修改链上状态。
 * @notice 这个要先使用：“forge create src/Counter.sol:FunctionOutputs \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast”部署，然后才能在链上读取。

  合约地址：0x5FbDB2315678afecb367f032d93F642f64180aa3
 */
contract FunctionOutputsV1 {
    function returnOne() public pure returns (uint256) {
        return 1;
    }

    function returnMany() public pure returns (uint256, bool, uint256) {
        return (1, true, 2);
    }
}

/**
 * @notice 这里开始解构赋值
 */
contract FunctionOutputsV2 {
    function returnMany() public pure returns (uint256, bool, uint256) {
        return (1, true, 2);
    }

    function named() public pure returns (uint256 x, bool y, uint256 z) {
        x = 1;
        y = true;
        z = 2;
    }

    function destructuring()
        public
        pure
        returns (uint256, bool, uint256, uint256, uint256)
    {
        (uint256 i, bool b, uint256 j) = returnMany();
        (uint256 x, , uint256 z) = returnMany();
        return (i, b, j, x, z);
    }
}
