use Mix.Config

config :eth_watcher, :enable_watcher, true
config :eth_watcher, :api_url, System.get_env("API_URL")

config :eth_watcher, EthWatcherWeb.Endpoint,
  load_from_system_env: true,
  url: [scheme: "http", host: {:system, "HOST"}, port: {:system, "PORT"}],
  check_origin: false,
  server: true

config :logger, level: :info

config :sentry,
  dsn: "https://c0a329ae6abc48f892b7e362501a0a42@sentry.io/1324779",
  environment_name: :prod,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!,
  tags: %{
    env: "production"
  },
  included_environments: [:prod]
