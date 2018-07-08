use Mix.Config

# General application configuration
config :plate_slate,
  ecto_repos: [PlateSlate.Repo]

# Configures the endpoint
config :plate_slate, PlateSlateWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JbSS+mF2qR3w+3PdYK4g4uBwTA48ZGF6sHpkt0tynRf4EIyrMp0aPb1CAmMgkrkL",
  render_errors: [view: PlateSlateWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PlateSlate.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env()}.exs"
