use Mix.Config

config :socket_gallows, SocketGallowsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PstftGn0JGWRqW+kHGFaETk2NwrNWxn7+15blgGjJwasS7xaGhrR89XsxELHFO5t",
  render_errors: [view: SocketGallowsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SocketGallows.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

import_config "#{Mix.env()}.exs"
