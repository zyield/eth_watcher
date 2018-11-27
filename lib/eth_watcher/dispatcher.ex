defmodule EthWatcher.Dispatcher do
  require Logger

  @base_url Application.get_env(:eth_watcher, :api_url)

  def dispatch(tx) when is_nil(tx), do: nil
  def dispatch(tx) do
    unless Mix.env() == :test, do: post(tx)
  end

  defp post(msg) do
    headers = [{"Content-Type", "application/vnd.api+json"}, {"Chainspark-secret", "123"}]

    with {:ok, payload} <- Poison.encode(msg),
         {:ok, _} <- HTTPoison.post(@base_url, payload, headers)
    do
      Logger.info "Transaction posted"
    else
      error ->
        case error do
          {:error, %HTTPoison.Error{id: nil, reason: :timeout}} ->
            Logger.error "HTTPoison Timeout"
          {:error, %HTTPoison.Error{id: nil, reason: reason}} ->
            Logger.error "Error with #{reason}"
          _ -> Logger.error "Uknown Error at dispatcher &post/1"
        end
    end
  end

end
