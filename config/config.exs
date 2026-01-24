import Config

config :code_my_spec, CodeMySpecWeb.Endpoint,
  server: false

config :code_my_spec, adapter: Ecto.Adapters.SQLite3

config :code_my_spec, CodeMySpec.Repo,
  database: Path.expand("~/.codemyspec/cli.db"),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  log: false

config :code_my_spec,
  ecto_repos: [CodeMySpec.Repo]

# Disable console logging to prevent cluttering the TUI
config :logger, :default_handler, false

# Configure file backend for logging
config :logger, :file_log,
  path: Path.expand(".code_my_spec/internal/cli.log"),
  level: :debug,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :mfa]

config :phoenix, :json_library, Jason

config :code_my_spec, CodeMySpec.Vault,
  ciphers: [
    default: {
      Cloak.Ciphers.AES.GCM,
      tag: "AES.GCM.V1",
      key: Base.decode64!("w09FSTq2MKlGVsfejph/sQiw6j9PSrqmgpCccRNG33s="),
      iv_length: 12
    }
  ]

import_config "#{config_env()}.exs"
