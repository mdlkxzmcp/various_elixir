use Mix.Config

config :gallows, GallowsWeb.Endpoint,
  http: [port: 4001],
  server: true

config :logger, level: :warn

config :hound, driver: "phantomjs"
