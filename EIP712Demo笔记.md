## 下面是学习EIP712Demo这个结构化签名的笔记

```shell
vincenthuang@VincentHuangdeMac-mini hello-web3
❯ forge script script/EIP712Demo.s.sol:EIP712DemoScript \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

[⠊] Compiling...
No files changed, compilation skipped
Script ran successfully.

## Setting up 1 EVM.

==========================

Chain 31337

Estimated gas price: 1.757608619 gwei

Estimated total gas used for script: 872968

Estimated amount required: 0.001534336080911192 ETH

==========================

##### anvil-hardhat
✅  [Success] Hash: 0x19847c1d5f0229fcbc2c7a7e9bdbc25ebdb1bcad0d21eb40eb3529fd825aa3a0
Contract Address: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
Block: 3
Paid: 0.000519665557866738 ETH (671514 gas * 0.773871517 gwei)

✅ Sequence #1 on anvil-hardhat | Total Paid: 0.000519665557866738 ETH (671514 gas * avg 0.773871517 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /Users/vincenthuang/web3-about/走进区块链的世界1-2/wtf-academy-学习指导/hello-web3/broadcast/EIP712Demo.s.sol/31337/run-latest.json

Sensitive values saved to: /Users/vincenthuang/web3-about/走进区块链的世界1-2/wtf-academy-学习指导/hello-web3/cache/EIP712Demo.s.sol/31337/run-latest.json

```

- 这是部署合约到链上，这里的合约地址是 **Contract Address: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0**

```shell
vincenthuang@VincentHuangdeMac-mini hello-web3
❯ cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 \
 "getTypedDataHash(address,uint256,string,uint256)(bytes32)" \
 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 123 "hello" 1 \
 --rpc-url http://127.0.0.1:8545

0x8e53a795691ab4ae22306c673a6c45fb82ebdbb8638d8f860faecd239c5dc522
```

- 这是运行合约中的 **getTypedDataHash** 函数，这里传入的参数分别是
  - 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
  - 123
  - "hello"
  - 1
- 注意这些参数和 **mail.json** 里面的某些参数是保持一致的。
- 尤其是合约地址 **0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0**，必须一致，不然无法运行。
- 这里是针对这些数据做的EIP712签名的hash值。

```shell
vincenthuang@VincentHuangdeMac-mini hello-web3
❯ cast wallet sign --data --from-file mail.json \
 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

0x47fb784e257e4468d15a9c716540799bd0f8efdbfb4889d8002f6f72b900e6eb29f84794bcebafdcbb27ec5f0f9c577a44ccfee31f38e47378db3e2afa42068d1c
```

- 这是对mail.json做签名，这里的到的是最终的签名。

```shell
vincenthuang@VincentHuangdeMac-mini hello-web3
❯ cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 \
 "recoverSigner(bytes32,bytes)(address)" \
 0x8e53a795691ab4ae22306c673a6c45fb82ebdbb8638d8f860faecd239c5dc522 \
 0x47fb784e257e4468d15a9c716540799bd0f8efdbfb4889d8002f6f72b900e6eb29f84794bcebafdcbb27ec5f0f9c577a44ccfee31f38e47378db3e2afa42068d1c \
 --rpc-url http://127.0.0.1:8545
0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```

- 这是运行合约中的 **recoverSigner** 函数，这里是从 typedDataHash + signature 恢复signer地址
- **0x8e53a795691ab4ae22306c673a6c45fb82ebdbb8638d8f860faecd239c5dc522** ，这是 **typedDataHash**
- **0x47fb784e257e4468d15a9c716540799bd0f8efdbfb4889d8002f6f72b900e6eb29f84794bcebafdcbb27ec5f0f9c577a44ccfee31f38e47378db3e2afa42068d1c ** ，这是最终的签名

```text
EIP712 的签名不能脱离 domain 单独使用；
如果 verifyingContract 改了，typedDataHash 就会变，旧签名会失效。
```

## 关于 mail.json 的说明

**把 `mail.json` 按 3W 来看最清楚：What / Why / When。**

```mermaid
flowchart LR
A[mail.json] --> B[描述 EIP712 要签的结构化数据]
B --> C[cast wallet sign --data 读取它]
C --> D[生成 signature]
D --> E[合约 recoverSigner 验签]
```

## 1. What: 它是什么？

`mail.json` 不是合约，也不是部署脚本。

它是一个：

```text
给钱包/命令行工具看的 EIP712 typed data 描述文件
```

你可以把它理解成：

| 类比                | 对应                      |
| ------------------- | ------------------------- |
| 合同模板 + 合同内容 | `mail.json`               |
| 用户签字            | `cast wallet sign --data` |
| 合约验签            | `recoverSigner(...)`      |

它里面主要有 4 块：

| 字段          | 作用                         |
| ------------- | ---------------------------- |
| `types`       | 定义数据结构长什么样         |
| `primaryType` | 这次主要签哪种结构           |
| `domain`      | 这份签名属于哪个项目/链/合约 |
| `message`     | 这次实际要签的数据           |

---

## 2. Why: 为什么要创建它？

因为 `cast wallet sign --data` 不能凭空知道你要签什么结构。

它需要一份“说明书”告诉它：

1. 这是什么结构
2. 这份结构有哪些字段
3. 每个字段是什么类型
4. 当前 domain 是什么
5. 这次具体值是什么

所以 `mail.json` 的作用就是：

```text
把 EIP712 的“结构 + 上下文 + 本次数据”一次性喂给签名工具。
```

如果没有它，工具就不知道怎么生成 EIP712 的最终 `typedDataHash`。

---

## 3. When: 什么时候需要它？

当你做的是：

```text
EIP712 签名
```

就常需要这种 JSON 结构。

常见场景：

| 场景                           | 会不会用到类似 JSON    |
| ------------------------------ | ---------------------- |
| 普通消息签名                   | 通常不需要             |
| EIP712 typed data 签名         | 很常需要               |
| 前端钱包签名 `signTypedData`   | 本质上也需要同样的信息 |
| Permit / 订单签名 / 白名单签名 | 非常常见               |

所以这不是“突然多出来的文件”，而是：

```text
EIP712 在命令行里的输入载体
```

---

## 怎么读 `mail.json`

你这份文件可以这样理解：

```json
{
  "types": { ... },
  "primaryType": "Mail",
  "domain": { ... },
  "message": { ... }
}
```

### `types`

定义模板：

```text
Mail 有 to / amount / message / nonce
```

### `primaryType`

说明这次主要签的是：

```text
Mail
```

### `domain`

说明上下文：

```text
WTF Academy
版本 1
链 31337
验签合约 0x9f...
```

### `message`

说明这次具体内容：

```text
给 Bob
123
hello
nonce = 1
```

---

## 一句话总理解

```text
mail.json = EIP712 签名时的“结构化签名说明书”
```

---

## 最后给你一个最短记忆版

| 问题         | 答案                                  |
| ------------ | ------------------------------------- |
| 它是什么     | EIP712 typed data 的 JSON 描述文件    |
| 为什么需要它 | 给签名工具提供结构、domain 和具体数据 |
| 什么时候用   | 做 EIP712 签名时                      |

---

## `mail.json` 的最小人话翻译

| 字段 | 人话理解 |
|---|---|
| `types` | 先定义表格模板 |
| `primaryType` | 这次签的是哪张表 |
| `domain` | 这张表属于哪个项目、版本、链、验签合约 |
| `message` | 这次表格里实际填写的内容 |

一句话再记一次：

```text
mail.json = 给 EIP712 签名工具看的结构化输入文件
```
