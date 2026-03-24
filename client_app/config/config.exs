import Config

config :client,
  default_config: [
    url:         "ws://localhost:4000/socket/websocket?vsn=2.0.0",
    json_library: Client.MyToon, # Using toon decoder/encoder
    topic:       "room:lobby"         # override per environment if needed
  ]

config :logger, :default_formatter, format: "[$level] $message\n"
config :logger, level: :debug
