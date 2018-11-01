defmodule EthWatcher.Replay do
  alias EthWatcher.Watcher

  def start(range) do
    Watcher.start_link(%{replay: true, range: range})
  end
end
