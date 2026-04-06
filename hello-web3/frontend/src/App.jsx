import { useEffect, useState } from "react";
import {
  createPublicClient,
  createWalletClient,
  custom,
  http,
} from "viem";
import { foundry } from "viem/chains";
import "./App.css";

/**
 * 这是 MinimalDapp.sol 这个合约的地址
 */
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
  {
    type: "function",
    name: "increment",
    inputs: [],
    outputs: [],
    stateMutability: "nonpayable",
  },
];

const publicClient = createPublicClient({
  chain: foundry,
  transport: http("http://127.0.0.1:8545"),
});

function App() {
  const [count, setCount] = useState("-");
  const [owner, setOwner] = useState("-");
  const [account, setAccount] = useState("");
  const [status, setStatus] = useState("正在读取链上数据...");
  const [isLoading, setIsLoading] = useState(false);
  const [isConnecting, setIsConnecting] = useState(false);
  const [isWriting, setIsWriting] = useState(false);

  async function loadContractData() {
    try {
      setIsLoading(true);
      setStatus("正在读取 count 和 owner...");

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

  async function connectWallet() {
    if (!window.ethereum) {
      setStatus("未检测到 MetaMask");
      return;
    }

    try {
      setIsConnecting(true);
      setStatus("正在请求连接钱包...");

      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });

      const selectedAccount = accounts[0] ?? "";
      setAccount(selectedAccount);
      setStatus("钱包连接成功");
    } catch (error) {
      console.error(error);
      setStatus("钱包连接失败，可能是你取消了授权");
    } finally {
      setIsConnecting(false);
    }
  }

  async function handleIncrement() {
    if (!window.ethereum) {
      setStatus("未检测到 MetaMask");
      return;
    }

    if (!account) {
      setStatus("请先连接钱包");
      return;
    }

    try {
      setIsWriting(true);
      setStatus("请在钱包中确认 increment() 交易...");

      const chainId = await window.ethereum.request({ method: "eth_chainId" });
      if (chainId !== "0x7a69") {
        setStatus("请先把 MetaMask 切换到 Anvil Local 网络");
        return;
      }

      const walletClient = createWalletClient({
        chain: foundry,
        transport: custom(window.ethereum),
      });

      const hash = await walletClient.writeContract({
        account,
        address: contractAddress,
        abi,
        functionName: "increment",
      });

      setStatus(`交易已发送: ${hash}`);

      // 钱包确认解决的是用户授权和签名
      // transaction receipt 解决的是链上最终状态确认。
      await publicClient.waitForTransactionReceipt({ hash });
      await loadContractData();

      setStatus(`increment() 已确认，上链哈希: ${hash}`);
    } catch (error) {
      console.error(error);
      setStatus("increment() 失败，请检查钱包确认状态或控制台报错");
    } finally {
      setIsWriting(false);
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
          现在我们已经能读链，接下来用 MetaMask 从前端发送 increment() 交易。
        </p>

        <div className="panel">
          <span className="label">钱包状态</span>
          <span className="value">{account || "未连接"}</span>
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
          <button onClick={connectWallet} disabled={isConnecting}>
            {isConnecting ? "连接中..." : "连接钱包"}
          </button>
          <button onClick={loadContractData} disabled={isLoading}>
            {isLoading ? "读取中..." : "重新读取"}
          </button>
        </div>

        <div className="actions">
          <button onClick={handleIncrement} disabled={isWriting}>
            {isWriting ? "交易处理中..." : "increment()"}
          </button>
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
