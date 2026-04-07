import { useEffect, useState } from "react";
import {
  BaseError,
  ContractFunctionExecutionError,
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
    type: "event",
    name: "CountUpdated",
    inputs: [
      {
        name: "caller",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "newCount",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
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
  {
    type: "function",
    name: "setCount",
    inputs: [{ name: "newCount", type: "uint256", internalType: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "error",
    name: "NotOwner",
    inputs: [],
  },
  {
    type: "error",
    name: "CountTooSmall",
    inputs: [
      { name: "currentCount", type: "uint256", internalType: "uint256" },
      { name: "requestedCount", type: "uint256", internalType: "uint256" },
    ],
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

  function getReadableErrorMessage(error) {
    if (error instanceof BaseError) {
      const revertError = error.walk(
        (err) => err instanceof ContractFunctionExecutionError,
      );

      if (revertError?.cause?.name === "NotOwner") {
        return "只有 owner 才能调用 setCount()。";
      }

      if (revertError?.cause?.name === "CountTooSmall") {
        const [currentCount, requestedCount] = revertError.cause.args ?? [];
        return `输入值太小。当前 count 是 ${currentCount?.toString()}，你传入的是 ${requestedCount?.toString()}。`;
      }
    }

    return "交易失败，请检查钱包确认状态或控制台报错。";
  }

  async function ensureCorrectChain() {
    const chainId = await window.ethereum.request({ method: "eth_chainId" });
    if (chainId !== "0x7a69") {
      setStatus("请先把 MetaMask 切换到 Anvil Local 网络");
      return false;
    }

    return true;
  }

  async function createAppWalletClient() {
    return createWalletClient({
      chain: foundry,
      transport: custom(window.ethereum),
    });
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

      const isCorrectChain = await ensureCorrectChain();
      if (!isCorrectChain) return;

      const walletClient = await createAppWalletClient();

      const hash = await walletClient.writeContract({
        account,
        address: contractAddress,
        abi,
        functionName: "increment",
      });

      setStatus(`交易已发送: ${hash}`);

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

  async function handleSetCount() {
    if (!window.ethereum) {
      setStatus("未检测到 MetaMask");
      return;
    }

    if (!account) {
      setStatus("请先连接钱包");
      return;
    }

    if (account.toLowerCase() !== owner.toLowerCase()) {
      setStatus("setCount(5) 失败：当前钱包不是owner。");
      return;
    }

    if (Number(count) >= 5) {
      setStatus(
        `setCount(5) 失败：当前 count 已经是 ${count}，不能设施成更小的 5。`,
      );
      return;
    }

    try {
      setIsWriting(true);
      setStatus("请在钱包中确认 setCount(5) 交易...");

      const isCorrectChain = await ensureCorrectChain();
      if (!isCorrectChain) return;

      const walletClient = await createAppWalletClient();

      const hash = await walletClient.writeContract({
        account,
        address: contractAddress,
        abi,
        functionName: "setCount",
        args: [5n],
      });

      setStatus(`交易已发送: ${hash}`);

      const receipt = await publicClient.waitForTransactionReceipt({ hash });

      console.log("交易回执", receipt);

      if (receipt.status !== "success") {
        setStatus("setCount(5) 已上链，但合约执行失败。当前钱包不是 owner。");
        return;
      }

      await loadContractData();

      setStatus(`setCount(5) 已确认，上链哈希: ${hash}`);
    } catch (error) {
      console.error("SetCount 交易失败", error);
      setStatus(getReadableErrorMessage(error));
    } finally {
      setIsWriting(false);
    }
  }

  useEffect(() => {
    let unwatchContractEvent;

    loadContractData();

    if (window.ethereum) {
      function handleAccountsChanged(accounts) {
        const nextAccount = accounts[0] ?? "";
        setAccount(nextAccount);

        if (nextAccount) {
          setStatus("检测到钱包账户切换");
        } else {
          setStatus("钱包已断开连接");
        }
      }

      function handleChainChanged() {
        setStatus("检测到网络切换，正在重新读取链上数据...");
        loadContractData();
      }

      window.ethereum.on("accountsChanged", handleAccountsChanged);
      window.ethereum.on("chainChanged", handleChainChanged);

      unwatchContractEvent = publicClient.watchContractEvent({
        address: contractAddress,
        abi,
        eventName: "CountUpdated",
        onLogs(logs) {
          console.log("监听到 CountUpdated 事件", logs);
          setStatus("监听到 CountUpdated 事件，正在同步最新状态...");
          loadContractData();
        },
      });

      return () => {
        window.ethereum.removeListener(
          "accountsChanged",
          handleAccountsChanged,
        );
        window.ethereum.removeListener("chainChanged", handleChainChanged);

        if (unwatchContractEvent) {
          unwatchContractEvent();
        }
      };
    }

    unwatchContractEvent = publicClient.watchContractEvent({
      address: contractAddress,
      abi,
      eventName: "CountUpdated",
      onLogs(logs) {
        console.log("监听到 CountUpdated 事件", logs);
        setStatus("监听到 CountUpdated 事件，正在同步最新状态...");
        loadContractData(); // 收到事件之后重新同步页面状态
      },
    });

    return () => {
      if (unwatchContractEvent) {
        unwatchContractEvent();
      }
    };
  }, []);

  return (
    <main className="app">
      <section className="card">
        <p className="eyebrow">Minimal DApp</p>
        <h1>Count 控制台</h1>
        <p className="description">
          现在我们已经能读链，接下来继续用 MetaMask
          从前端发送交易，并开始处理合约错误。
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
          <button onClick={handleSetCount} disabled={isWriting}>
            {isWriting ? "交易处理中..." : "setCount(5)"}
          </button>
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
