use Mix.Config

config :eth_watcher, :enable_watcher, false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :eth_watcher, EthWatcherWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
