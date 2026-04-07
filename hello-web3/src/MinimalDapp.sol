// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
这段是命令+返回信息
cast logs \
  --rpc-url http://127.0.0.1:8545 \
  --address 0x5FbDB2315678afecb367f032d93F642f64180aa3

- address: 0x5FbDB2315678afecb367f032d93F642f64180aa3 这是MinimalDapp这个合约的地址
  blockHash: 0x07ab271cf4786bdcb0b2877114a3ba45fd917f068a89dbc0c435c73e073d0d9e 
  blockNumber: 2
  data: 0x0000000000000000000000000000000000000000000000000000000000000001 这里表示newCount的值，也就是1
  logIndex: 0
  removed: false
  topics: [
        0x170de63abeb5e32b35c3def75defe334590e5fdcf704dba0c988ab49e6e4cec0 这里是事件签名，表示是哪个事件发的信息
        0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266 这里表示indexed参数，也就是caller的值，这个可以在下面代码找到
  ]
  transactionHash: 0xd1388223157c283b83d7eedd3c8a1c56b324149aed39b788bcb1040ad8ac1d98
  transactionIndex: 0
- address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
  blockHash: 0xed5d342e248d0e32e65de4f33935a4f64921f53b1172344b5882312f97b9f9fd
  blockNumber: 3
  data: 0x0000000000000000000000000000000000000000000000000000000000000005
  logIndex: 0
  removed: false
  topics: [
        0x170de63abeb5e32b35c3def75defe334590e5fdcf704dba0c988ab49e6e4cec0
        0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266
  ]
  transactionHash: 0xf9b8d7be701a14646e6ec5056fcf3a39fd0255ab6e580606467afab3295cf2ce
  transactionIndex: 0
 */
contract MinimalDapp {
    // 前端最常读取的链上状态。
    uint256 public count;
    // 记录部署者地址，后面用它做最小权限控制。
    address public owner;

    // 前端监听这个事件，就能知道是谁把 count 改成了多少。
    // 这里的 indexed 表示把 caller 写入 topics，方便前端过滤和查询。
    // 用 cast logs 看这类日志时：
    // 1. address 是发出日志的合约地址
    // 2. topics[0] 是事件签名哈希
    // 3. topics[1] 是 indexed 的 caller
    // 4. data 是未 indexed 的 newCount
    event CountUpdated(address indexed caller, uint256 newCount);

    // 非 owner 调用 setCount 时抛出的自定义错误。
    error NotOwner();
    // 传入的目标值比当前值还小时抛出的自定义错误。
    error CountTooSmall(uint256 currentCount, uint256 requestedCount);

    constructor() {
        // 部署合约的人会成为 owner。
        owner = msg.sender;
    }

    /**
     * @notice 只有 owner 才能直接把 count 改成指定值。
     * @dev 如果当前 count 是 5，而你传入 3，就会 revert CountTooSmall(5, 3)。
     */
    function setCount(uint256 newCount) public {
        if (msg.sender != owner) {
            // 前端会根据 ABI 解码这个自定义错误，再展示成用户能看懂的提示。
            revert NotOwner();
        }

        if (newCount < count) {
            revert CountTooSmall(count, newCount);
        }

        count = newCount;
        // 写操作成功后发事件，前端可据此刷新界面。
        emit CountUpdated(msg.sender, newCount);
    }

    function increment() public {
        // 最小写操作示例：任何人都可以把 count 加 1。
        count = count + 1;
        emit CountUpdated(msg.sender, count);
    }

    function increaseBy(uint256 step) public {
        // 给前端输入框练习用：任何人都可以把 count 增加指定值。
        count = count + step;
        emit CountUpdated(msg.sender, count);
    }
}
