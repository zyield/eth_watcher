defmodule EthWatcher.Watcher do
  use GenServer
  require Logger

  alias EthWatcher.Dispatcher
  alias EthWatcher.Util


  @infura "https://mainnet.infura.io/v3/ac1b630668ed483cbe7aef78280f38b3"
  @wei_threshold 1_000 * :math.pow(10, 18)
  @transfer_signature "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    Process.get(:hash)
    |> work

    schedule_work()
    {:noreply, state}
  end

  def schedule_work do
    Process.send_after(self(), :work, 1000)
  end

  def work(prev_hash) do
    case get_latest_block() do
      {:ok, block = %{"hash" => hash}} ->
        unless prev_hash == hash, do: process_block(block)
        Process.put(:hash, hash)
      {:error, _} -> Logger.info "Error getting block"
    end
  end

  def get_latest_block, do: query_jsonrpc("eth_getBlockByNumber", ["latest", true])

  def process_block(%{"transactions" => transactions}) do
    Task.start(fn -> process_transactions(transactions) end)
  end

  def process_transactions(nil), do: nil
  def process_transactions(transactions) do
    transactions
    |> Enum.map(&add_token_details/1)
    |> Enum.map(&process_tx/1)
  end

  def add_token_details(tx = %{"input" => input, "value" => value}) when input == "0x" do
    token_amount = value
                |> Util.parse_value

    tx |> Map.merge(%{
      "symbol" => "ETH",
      "token_amount" => "#{token_amount}",
      "is_token_tx" => false
    })
  end

  def add_token_details(tx) do
    tx |> Map.put("is_token_tx", true)
  end

  def process_tx(tx = %{"is_token_tx" => true}), do: process_token_tx(tx)
  def process_tx(tx), do: process_eth_tx(tx)

  def process_token_tx(%{"hash" => hash, "is_token_tx" => is_token_tx}) do
    with {:ok, %{"logs" => logs}} <- get_transaction_receipt(hash) do
      transfer_log = logs |> get_transfer_log

      unless is_nil transfer_log do
        {from, to, value} = transfer_log
                            |> decode_topics

        token_amount = value
                      |> Util.parse_value
        %{
          from: from,
          to: to,
          value: value,
          token_amount: "#{token_amount}",
          is_token_tx: is_token_tx,
          hash: hash,
          transfer_log: transfer_log
        }
        |> send
      end
    end
  end

  def process_eth_tx(tx = %{"token_amount" => token_amount}) do
    {wei, _} = token_amount |> Integer.parse
    unless is_below_threshold?(wei) do
      %{
        from: tx["from"],
        to: tx["to"],
        symbol: "ETH",
        decimals: tx["decimals"],
        hash: tx["hash"],
        value: tx["value"],
        token_amount: tx["token_amount"],
        is_token_tx: tx["is_token_tx"]
      }
      |> send
    end
  end

  def send(transaction) do
    # Dispatcher.dispatch(transaction)
    IO.inspect transaction
    transaction
  end

  def get_transfer_log(logs) when not is_nil(logs) and length(logs) > 0 do
    logs |> Enum.find(&is_transfer_log?/1)
  end
  def get_transfer_log(_), do: nil

  def get_transaction_receipt(hash) do
    # Receipt is not available for pending transactions and returns nil.
    query_jsonrpc("eth_getTransactionReceipt", [hash])
  end

  defp query_jsonrpc(method, params) do
    data = %{
      jsonrpc: "2.0",
      method: method,
      params: params,
      id: 1
    }
    headers = [{"Content-Type", "application/json"}]
    with {:ok, payload} <- Poison.encode(data),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.post(@infura, payload, headers),
         {:ok, %{"result" => result}  } <- Poison.decode(body) do
      {:ok, result}

    end
  end

  defp decode_topics(%{"topics" => topics}) when length(topics) < 3, do: {0, 0, 0}
  defp decode_topics(%{"topics" => topics, "data" => data}) do
    from = topics |> Enum.at(1) |> String.slice(26..-1)
    to = topics |> Enum.at(2) |> String.slice(26..-1)

    {"0x" <> from, "0x" <> to, data}
  end

  def is_transfer_log?(log), do: log["topics"] |> Enum.at(0) == @transfer_signature

  def is_below_threshold?("0"), do: true
  def is_below_threshold?(value), do: value < @wei_threshold
end
