import Config

# Disable console logging to prevent cluttering the TUI
config :logger, :default_handler, false

# Configure file backend for logging (added via LoggerBackends in Application.start)
config :logger, :file_log,
  path: Path.expand("~/.codemyspec/cli.log"),
  level: :debug,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :mfa]
