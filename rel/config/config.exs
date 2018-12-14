use Mix.Config

port = String.to_integer(System.get_env("PORT") || "4000")

config :eth_watcher, :api_url, System.get_env("API_URL")

config :chainspark_api, EthWatcherWeb.Endpoint,
  http: [port: port],
  url: [scheme: "http", host: System.get_env("HOST"), port: port],
  check_origin: false,
  server: true

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: :prod,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!,
  tags: %{
    env: "production"
  },
  included_environments: [:prod]
