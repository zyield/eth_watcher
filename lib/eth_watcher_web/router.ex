defmodule EthWatcherWeb.Router do
  use EthWatcherWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EthWatcherWeb do
    pipe_through :api

    post "/replay", WatcherController, :replay
  end
end
