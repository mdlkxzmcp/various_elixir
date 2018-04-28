use Mix.Config

config :gallows, GallowsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "i9ZcdHkWObmbg9tS0qJ1xsujADRAtUsXunYiqerOvoVNMGOy+z/LeZzal9nbpUKt",
  render_errors: [view: GallowsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Gallows.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

import_config "#{Mix.env()}.exs"
