defmodule EthWatcher.Mixfile do
  use Mix.Project

  def project do
    [
      app: :eth_watcher,
      version: "0.0.3",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {EthWatcher.Application, []},
      extra_applications: [:sentry, :logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:number, "~> 0.5.6"},
      {:httpoison, "~> 1.0"},
      {:plug_cowboy, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:sentry, "~> 7.0"},
      {:jason, "~> 1.1"},
      {:distillery, "~> 2.0"}
    ]
  end
end
