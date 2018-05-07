use Mix.Config

config :socket_gallows, SocketGallowsWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn
