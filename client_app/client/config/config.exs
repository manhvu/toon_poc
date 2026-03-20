import Config

config :client,
  default_config: [
    uri: "ws://localhost:4000/socket/websocket?vsn=2.0.0",
    json_parser: Client.MyToon,
     # serializer: Client.MyToon
  ]

config :elixir, :protocol_consolidation, false

# Do not include metadata nor timestamps in development logs
config :logger, :default_formatter, format: "[$level] $message\n"

# Do not print debug messages in production
config :logger, level: :debug
