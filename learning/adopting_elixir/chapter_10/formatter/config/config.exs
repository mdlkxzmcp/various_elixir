use Mix.Config

config :logger, :console,
  format: {Formatter, :json_formatter},
  metadata: [:application, :file, :line, :module]
