import { useEffect, useState } from "react";
import { createPublicClient, http } from "viem";
import { foundry } from "viem/chains";
import "./App.css";

const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

const abi = [
  {
    type: "function",
    name: "count",
    inputs: [],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "owner",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "view",
  },
];

/**
 * viem 的方法
 * 这个库就是用来跟链通讯的
 */
const publicClient = createPublicClient({
  chain: foundry,
  transport: http("http://127.0.0.1:8545"),
});

/**
 * 读合约通常不需要钱包，因为它只是对链上状态做只读查询，不会产生交易，也不需要签名。
 * 写合约会修改链上状态，本质上是发送一笔交易，所以必须由用户钱包签名，并由该账户承担 gas。
 * @returns 
 */
function App() {
  const [count, setCount] = useState("-");
  const [owner, setOwner] = useState("-");
  const [status, setStatus] = useState("正在读取链上数据...");
  const [isLoading, setIsLoading] = useState(false);

  async function loadContractData() {
    try {
      setIsLoading(true);
      setStatus("正在读取 count 和 owner...");

      // 这里相当于 cast call
      const currentCount = await publicClient.readContract({
        address: contractAddress,
        abi,
        functionName: "count",
      });

      const currentOwner = await publicClient.readContract({
        address: contractAddress,
        abi,
        functionName: "owner",
      });

      // count 对应 Solidity 的 uint256，viem 读出来是 bigint。
      // 因为 bigint 不适合直接按普通数字处理，而且 uint256 可能超过 JS number 的安全范围，所以前端通常会先转成 string 再展示。
      // owner 本身就是地址字符串，所以可以直接显示。
      setCount(currentCount.toString());
      setOwner(currentOwner);
      setStatus("读取成功");
    } catch (error) {
      console.error(error);
      setStatus("读取失败，请检查本地链和合约地址");
    } finally {
      setIsLoading(false);
    }
  }

  useEffect(() => {
    loadContractData();
  }, []);

  return (
    <main className="app">
      <section className="card">
        <p className="eyebrow">Minimal DApp</p>
        <h1>Count 控制台</h1>
        <p className="description">
          现在我们先完成前端最小读链闭环：页面加载后读取 count 和 owner。
        </p>

        <div className="panel">
          <span className="label">钱包状态</span>
          <span className="value">未连接</span>
        </div>

        <div className="panel">
          <span className="label">当前 count</span>
          <span className="value">{count}</span>
        </div>

        <div className="panel">
          <span className="label">owner</span>
          <span className="value">{owner}</span>
        </div>

        <div className="actions">
          <button disabled>连接钱包</button>
          <button onClick={loadContractData} disabled={isLoading}>
            {isLoading ? "读取中..." : "重新读取"}
          </button>
        </div>

        <div className="actions">
          <button disabled>increment()</button>
          <button disabled>setCount(5)</button>
        </div>

        <div className="panel">
          <span className="label">状态消息</span>
          <span className="value">{status}</span>
        </div>
      </section>
    </main>
  );
}

export default App;
