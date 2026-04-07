import { useEffect, useState } from "react";
import {
  UserRejectedRequestError,
  ContractFunctionRevertedError,
  BaseError,
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
      const rejectedError = error.walk(
        (err) => err instanceof UserRejectedRequestError,
      );

      if (rejectedError) {
        return "你在钱包里取消了这笔交易。";
      }

      const revertedError = error.walk(
        (err) => err instanceof ContractFunctionRevertedError,
      );

      console.log("ContractFunctionRevertedError 数据", revertedError);

      if (revertedError?.data?.errorName === "NotOwner") {
        return "只有 owner 才能调用 setCount()。";
      }

      if (revertedError?.data?.errorName === "CountTooSmall") {
        const [currentCount, requestedCount] = revertedError.data.args ?? [];
        return `输入值太小。当前 count 是 ${currentCount?.toString()}，你传入的是 ${requestedCount?.toString()}。`;
      }

      // ABI 没完全命中时，退回到 message 文本兜底。
      if (error.message.includes("NotOwner")) {
        return "只有 owner 才能调用 setCount()。";
      }

      if (error.message.includes("CountTooSmall")) {
        return "输入值太小，setCount(5) 没有通过合约校验。";
      }

      if (error.shortMessage) {
        return `交易失败：${error.shortMessage}`;
      }
    }

    return "交易失败，请检查钱包确认状态或控制台报错。";
  }

  function getDecodedContractError(error) {
    if (!(error instanceof BaseError)) return null;

    const revertedError = error.walk(
      (err) => err.name === "ContractFunctionRevertedError",
    );

    if (!revertedError?.data?.errorName) return null;

    return {
      name: revertedError.data.errorName,
      args: revertedError.data.args ?? [],
    };
  }

  function getSetCountExpectation() {
    if (!account) {
      return "先连接钱包，再测试 setCount(5) 的成功或失败分支。";
    }

    if (owner === "-" || count === "-") {
      return "请先读取最新链上数据。";
    }

    if (account.toLowerCase() !== owner.toLowerCase()) {
      return "当前账户不是 owner，合约预计抛出 NotOwner()。";
    }

    if (Number(count) >= 5) {
      return `当前账户虽然是 owner，但 5 小于等于当前 count=${count}，合约预计抛出 CountTooSmall(...)。`;
    }

    return "当前条件满足，setCount(5) 预计成功。";
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

    try {
      setIsWriting(true);
      setStatus(`准备发送 setCount(5)。预期结果：${getSetCountExpectation()}`);

      const isCorrectChain = await ensureCorrectChain();
      if (!isCorrectChain) return;

      try {
        await publicClient.simulateContract({
          account,
          address: contractAddress,
          abi,
          functionName: "setCount",
          args: [5n],
        });
      } catch (error) {
        const decodedError = getDecodedContractError(error);

        console.error("SetCount 预执行失败", error);
        if (decodedError) {
          console.log("SetCount 预执行解码后的合约错误", decodedError);
        }
        setStatus(getReadableErrorMessage(error));
        return;
      }

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
        setStatus("setCount(5) 已上链，但合约执行失败。");
        return;
      }

      await loadContractData();

      setStatus(`setCount(5) 已确认，上链哈希: ${hash}`);
    } catch (error) {
      const decodedError = getDecodedContractError(error);

      console.error("SetCount 交易失败", error);
      if (decodedError) {
        console.log("SetCount 解码后的合约错误", decodedError);
      }
      setStatus(getReadableErrorMessage(error));
    } finally {
      setIsWriting(false);
    }
  }

  useEffect(() => {
    let unwatchContractEvent;

    loadContractData();

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
          这一轮只收口一件事：让 setCount(5) 失败时，
          页面能把链上错误翻译成人能看懂的话。
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

        <div className="panel">
          <span className="label">setCount(5) 预期</span>
          <span className="value">{getSetCountExpectation()}</span>
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
