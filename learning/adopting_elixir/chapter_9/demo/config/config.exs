use Mix.Config

# General application configuration
config :demo,
  ecto_repos: [Demo.Repo]

# Configures the endpoint
config :demo, DemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "90p2vH739eB1AeNVSdVz2A69jbfcdMAsrvniaERFShsfKs2xdElBLrvgOhh27tlp",
  render_errors: [view: DemoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Demo.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Configures Ecto logging
config :demo, Demo.Repo, loggers: [Ecto.LogEntry, Demo.EctoInspector]

# Configures Phoenix instrumentation
config :demo, DemoWeb.Endpoint, instrumenters: [DemoWeb.PhoenixInspector]

import_config "#{Mix.env()}.exs"
