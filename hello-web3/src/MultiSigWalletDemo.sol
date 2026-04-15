// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MultiSigWalletDemo {
    // 这个indexed是“索引”，方便被链下按条件过滤搜索日志。
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event Submit(uint256 indexed txId);
    event Confirm(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmCount;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint256 txId) {
        require(txId < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint256 txId) {
        require(!transactions[txId].executed, "tx already executed");
        _;
    }

    // 保证当前这个owner还没有确认过这笔交易，防止同一个人重复确认刷屏。
    modifier notApproved(uint256 txId) {
        require(!approved[txId][msg.sender], "tx already approved");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "owners required");
        require(
            _required > 0 && _required <= _owners.length,
            "invalid required count"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "zero owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    receive() external payable {
        // 存入，这是一个要拿到share的操作 (这种是ERC4626的思路，不是多签钱包)。多签钱包中，用户往钱包打钱，增加余额。
        // 谁，存多少，当前用户的最终财政状况。正确的理解是：谁存钱，存多少，当前钱包合约余额。
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    // 负责创建提案
    function submit(
        address to,
        uint256 value,
        bytes memory data
    ) external onlyOwner {
        transactions.push(
            Transaction({
                to: to,
                value: value,
                data: data,
                executed: false,
                confirmCount: 0
            })
        );

        emit Submit(transactions.length - 1);
    }

    /**
     * @notice 这里的运行先决条件是：没有核准过的交易/没有执行过的交易/存在的交易/拥有者信息是唯一
     */
    function confirm(
        uint256 txId
    ) external onlyOwner txExists(txId) notExecuted(txId) notApproved(txId) {
        approved[txId][msg.sender] = true;
        transactions[txId].confirmCount += 1;

        emit Confirm(msg.sender, txId);
    }

    function execute(
        uint256 txId
    ) external onlyOwner txExists(txId) notExecuted(txId) {
        Transaction storage transaction = transactions[txId];
        require(
            transaction.confirmCount >= required,
            "not enough confirmations"
        );

        transaction.executed = true;

        // 让多签钱包调用目标地址，并且顺便转ETH和data。
        // 这里的to，其实就是目标客户的钱包，这样搞就能直接转钱。
        // 向目标地址发起一次外部调用。
        (bool ok, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(ok, "tx failed");

        emit Execute(txId);
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(
        uint256 txId
    )
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 confirmCount
        )
    {
        Transaction storage transaction = transactions[txId];
        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.confirmCount
        );
    }
}
