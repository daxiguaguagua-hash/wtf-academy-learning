// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// 这里是第六章内容。
contract ArrayAndStruct {
    uint256[3] public fixedNumbers = [uint256(1), 2, 3];
    // 数组用来存储同类型数据，这个是“合约的状态变量”，默认就是storage，存储在链上。
    uint256[] public dynamicNumbers;
    struct Student {
        string name;
        uint256 score;
        address wallet;
    }

    Student[] public students;

    constructor() {
        dynamicNumbers.push(10);
        dynamicNumbers.push(20);
    }

    /**
     * @notice 这里的dynamicNumbers默认是storage，返回的时候才会拷贝成memory
     */
    function getDynamicNumbers() public view returns (uint256[] memory) {
        return dynamicNumbers;
    }

    function pushDynamicNumber(uint256 newNumber) public {
        dynamicNumbers.push(newNumber);
    }

    function addStudent(
        string memory name,
        uint256 score,
        address wallet
    ) public {
        students.push(Student({name: name, score: score, wallet: wallet}));
    }

    /**
     * @notice 这里的string是‘引用类型’，需要使用memory。别的就不需要了因为是“值类型”
     * @notice ABI = Application Binary Interface，应用二进制接口，是智能合约与外界交互的标准接口。
     * @notice 它定义了函数的输入输出格式，使得外部应用能够正确调用智能合约的函数并理解返回的数据。
     */
    function getStudent(
        uint256 index
    ) public view returns (string memory, uint256, address) {
        Student storage student = students[index];
        return (student.name, student.score, student.wallet);
    }
}
