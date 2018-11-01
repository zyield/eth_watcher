defmodule EthWatcherWeb.WatcherController do
  use EthWatcherWeb, :controller
  alias EthWatcher.Replay

  def replay(conn, %{"from" => from, "to" => to}) do
    Replay.start(String.to_integer(from)..String.to_integer(to))

    conn
    |> send_resp(201, "Event Created")
  end
end
