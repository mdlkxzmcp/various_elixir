use Mix.Config

config :demo, DemoWeb.Endpoint,
  load_from_system_env: true,
  http: [port: 4040, protocol_options: [max_keepalive: 5_000_000]],
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :warn

import_config "prod.secret.exs"
