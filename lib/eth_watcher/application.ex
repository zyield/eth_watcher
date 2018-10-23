defmodule EthWatcher.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised

    children = 
      unless Mix.env() == :test do
        [
          supervisor(EthWatcherWeb.Endpoint, []),
          supervisor(EthWatcher.Watcher, [])
        ]
      else
        [supervisor(EthWatcherWeb.Endpoint, [])]
      end
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EthWatcher.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EthWatcherWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
