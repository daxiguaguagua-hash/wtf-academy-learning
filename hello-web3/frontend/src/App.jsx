import { useEffect, useState } from "react";
import {
  BaseError,
  UserRejectedRequestError,
  createPublicClient,
  createWalletClient,
  custom,
  formatEther,
  formatGwei,
  http,
} from "viem";
import { sepolia } from "viem/chains";
import "./App.css";

/**
 * 通过环境变量注入当前部署到 Sepolia 的 MessageBoard 地址。
 */
const contractAddress =
  import.meta.env.VITE_MESSAGEBOARD_ADDRESS ??
  "0x0000000000000000000000000000000000000000";

const rpcUrl =
  import.meta.env.VITE_SEPOLIA_RPC_URL ??
  "https://ethereum-sepolia-rpc.publicnode.com";

const chainIdFromEnv = import.meta.env.VITE_CHAIN_ID ?? "0xaa36a7";

const abi = [
  {
    type: "event",
    name: "MessageUpdated",
    inputs: [
      {
        name: "caller",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "newMessage",
        type: "string",
        indexed: false,
        internalType: "string",
      },
    ],
    anonymous: false,
  },
  {
    type: "function",
    name: "author",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "message",
    inputs: [],
    outputs: [{ name: "", type: "string", internalType: "string" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "setMessage",
    inputs: [{ name: "newMessage", type: "string", internalType: "string" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
];

const publicClient = createPublicClient({
  chain: sepolia,
  transport: http(rpcUrl),
});

function App() {
  const [message, setMessage] = useState("-");
  const [author, setAuthor] = useState("-");
  const [draftMessage, setDraftMessage] = useState("Hello from frontend!");
  const [account, setAccount] = useState("");
  const [status, setStatus] = useState("正在读取链上留言...");
  const [isLoading, setIsLoading] = useState(false);
  const [isConnecting, setIsConnecting] = useState(false);
  const [isWriting, setIsWriting] = useState(false);
  const [lastTxHash, setLastTxHash] = useState("");
  const [lastGasUsed, setLastGasUsed] = useState("-");
  const [lastGasPrice, setLastGasPrice] = useState("-");
  const [lastTxFee, setLastTxFee] = useState("-");

  async function loadMessage() {
    try {
      setIsLoading(true);
      setStatus("正在读取最新 message 和 author...");

      const currentMessage = await publicClient.readContract({
        address: contractAddress,
        abi,
        functionName: "message",
      });

      const currentAuthor = await publicClient.readContract({
        address: contractAddress,
        abi,
        functionName: "author",
      });

      setMessage(currentMessage);
      setAuthor(currentAuthor);
      setStatus("读取成功");
    } catch (error) {
      console.error(error);
      setStatus("读取失败，请检查 Sepolia RPC 和 MessageBoard 合约地址");
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

  async function ensureCorrectChain() {
    const chainId = await window.ethereum.request({ method: "eth_chainId" });
    const chainIdHex = `0x${Number(chainIdFromEnv).toString(16)}`;
    if (chainId !== chainIdHex) {
      // console.log(
      //   "chainId:",
      //   chainId,
      //   "expected:",
      //   chainIdFromEnv,
      //   "chainIdHex:",
      //   chainIdHex,
      // );
      setStatus("请先把 MetaMask 切换到 Ethereum Sepolia 网络");
      return false;
    }

    return true;
  }

  async function createAppWalletClient() {
    return createWalletClient({
      chain: sepolia,
      transport: custom(window.ethereum),
    });
  }

  function getReadableErrorMessage(error) {
    if (error instanceof BaseError) {
      const rejectedError = error.walk(
        (err) => err instanceof UserRejectedRequestError,
      );

      if (rejectedError) {
        return "你在钱包里取消了这笔交易。";
      }

      if (error.message.includes("Empty message")) {
        return "留言不能为空。";
      }

      if (error.shortMessage) {
        return `交易失败：${error.shortMessage}`;
      }
    }

    return "写入留言失败，请检查钱包确认状态或控制台报错";
  }

  async function handleSetMessage() {
    if (!window.ethereum) {
      setStatus("未检测到 MetaMask");
      return;
    }

    if (!account) {
      setStatus("请先连接钱包");
      return;
    }

    if (!draftMessage.trim()) {
      setStatus("请输入一条非空留言");
      return;
    }

    if (contractAddress === "0x0000000000000000000000000000000000000000") {
      setStatus("请先在 .env 中配置 VITE_MESSAGEBOARD_ADDRESS");
      return;
    }

    try {
      setIsWriting(true);
      setStatus("请在钱包中确认 setMessage(string) 交易...");

      const isCorrectChain = await ensureCorrectChain();
      if (!isCorrectChain) return;

      const walletClient = await createAppWalletClient();

      const hash = await walletClient.writeContract({
        account,
        address: contractAddress,
        abi,
        functionName: "setMessage",
        args: [draftMessage],
      });

      setLastTxHash(hash);
      setStatus(`交易已发送: ${hash}`);

      const receipt = await publicClient.waitForTransactionReceipt({ hash });
      const gasUsed = receipt.gasUsed;
      const gasPrice = receipt.effectiveGasPrice ?? 0n;
      const txFee = gasUsed * gasPrice;

      setLastGasUsed(gasUsed.toString());
      setLastGasPrice(`${formatGwei(gasPrice)} gwei`);
      setLastTxFee(`${formatEther(txFee)} ETH`);

      await loadMessage();

      setStatus(`setMessage(string) 已确认，上链哈希: ${hash}`);
    } catch (error) {
      console.error("setMessage 交易失败", error);
      setStatus(getReadableErrorMessage(error));
    } finally {
      setIsWriting(false);
    }
  }

  useEffect(() => {
    let unwatchContractEvent;

    console.log("开始监听 MessageUpdated 事件");

    if (contractAddress === "0x0000000000000000000000000000000000000000") {
      setStatus("请先在 .env 中配置 VITE_MESSAGEBOARD_ADDRESS");
      return;
    }

    loadMessage();

    unwatchContractEvent = publicClient.watchContractEvent({
      address: contractAddress,
      abi,
      eventName: "MessageUpdated",
      poll: true,
      pollingInterval: 1_000,
      batch: false,
      onLogs(logs) {
        console.log("监听到 MessageUpdated 事件", logs);
        setStatus("监听到 MessageUpdated 事件，正在同步最新留言...");
        loadMessage();
      },
      onError(error) {
        console.error("监听 MessageUpdated 事件失败", error);
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
        setStatus("检测到网络切换，正在重新读取最新留言...");
        loadMessage();
      }

      window.ethereum.on("accountsChanged", handleAccountsChanged);
      window.ethereum.on("chainChanged", handleChainChanged);

      return () => {
        console.log("停止监听 MessageUpdated 事件");
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
      console.log("停止监听 MessageUpdated 事件");
      if (unwatchContractEvent) {
        unwatchContractEvent();
      }
    };
  }, []);

  return (
    <main className="app">
      <section className="card">
        <p className="eyebrow">MessageBoard</p>
        <h1>链上留言板</h1>
        <p className="description">
          这一轮只练最小闭环：读取当前留言、输入新留言、发送交易写链，
          再通过事件监听自动同步页面。
        </p>

        <div className="panel">
          <span className="label">钱包状态</span>
          <span className="value">{account || "未连接"}</span>
        </div>

        <div className="panel">
          <span className="label">当前 message</span>
          <span className="value">{message}</span>
        </div>

        <div className="panel">
          <span className="label">当前 author</span>
          <span className="value">{author}</span>
        </div>

        <div className="panel panel-column">
          <span className="label">新留言</span>
          <textarea
            rows="4"
            value={draftMessage}
            onChange={(event) => setDraftMessage(event.target.value)}
            placeholder="输入你想写到链上的留言"
          />
        </div>

        <div className="actions">
          <button onClick={connectWallet} disabled={isConnecting}>
            {isConnecting ? "连接中..." : "连接钱包"}
          </button>
          <button onClick={loadMessage} disabled={isLoading}>
            {isLoading ? "读取中..." : "重新读取"}
          </button>
        </div>

        <div className="actions actions-single">
          <button onClick={handleSetMessage} disabled={isWriting}>
            {isWriting ? "交易处理中..." : "setMessage(string)"}
          </button>
        </div>

        <div className="panel">
          <span className="label">状态消息</span>
          <span className="value">{status}</span>
        </div>

        <div className="panel panel-column">
          <span className="label">最近一次交易</span>
          <span className="value">
            {lastTxHash ? (
              <>
                <strong>交易哈希：</strong>
                {lastTxHash}
                <br />
                <strong>gasUsed：</strong>
                {lastGasUsed}
                <br />
                <strong>gasPrice：</strong>
                {lastGasPrice}
                <br />
                <strong>总花费：</strong>
                {lastTxFee}
              </>
            ) : (
              "还没有发送过交易"
            )}
          </span>
        </div>
      </section>
    </main>
  );
}

export default App;
