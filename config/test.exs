import Config

config :code_my_spec, CodeMySpec.Repo,
  database: Path.expand("~/.codemyspec/cli_test.db"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
