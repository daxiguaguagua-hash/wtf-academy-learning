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

/**
 * @notice storage和memory的区别：
 * @notice storage：存储在区块链上，修改会改变链上状态
 * @notice memory：存储在内存中，修改不会改变链上状态
 */
contract DataStorage {
    uint256[] public numbers = [1, 2, 3];

    function getNumbers() public view returns (uint256[] memory) {
        return numbers;
    }

    function changeWithStorage() public {
        uint256[] storage nums = numbers;
        nums[0] = 100;
    }

    function changeWithMemory() public view returns (uint256[] memory) {
        uint256[] memory nums = numbers;
        nums[0] = 999;
        return nums;
    }
}

contract DataLocations {
    /**
     * @notice 获取合约里面的numbers使用的命令是：
     *  cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "numbers(uint256)(uint256)" 0 \
     *  --rpc-url http://127.0.0.1:8545
     *  因为这里public numbers会生成一个类似于getter的函数，所以要这样使用。这里的第一个uint256是getters的传入参数，uint256是返回值。
     */
    uint256[] public numbers = [1, 2, 3];

    function getNumbers() public view returns (uint256[] memory) {
        return numbers;
    }

    function changeWithStorage() public {
        uint256[] storage nums = numbers;
        nums[0] = 100;
    }

    function changeWithMemory() public view returns (uint256[] memory) {
        uint256[] memory nums = numbers;
        nums[0] = 999;
        return nums;
    }

    /**
     * @notice 这里的external主要是给合约外部调用。相对的还有public、internal、private等修饰符。
     * @notice public 合约内外都能调用/internal只有当前合约和子合约能调用/private只有当前合约内部能够调用。
     */
    function sum(uint256[] calldata arr) external pure returns (uint256 total) {
        for (uint256 i = 0; i < arr.length; i++) {
            total += arr[i];
        }
    }
}
