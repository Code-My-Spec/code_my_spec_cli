defmodule CodeMySpecCli.Application do
  @moduledoc """
  CLI application.

  CLI args come from either:
  - Application env :cli_args (set by mix task)
  - Burrito.Util.Args (when running as binary)
  """
  use Application
  alias Burrito.Util.Args

  @impl true
  def start(_type, _start_args) do
    ensure_db_directory()
    ensure_log_directory()
    setup_file_logger()

    args = get_cli_args()

    children = [
      CodeMySpecCli.WebServer.Telemetry,
      CodeMySpec.Repo,
      CodeMySpec.Vault,
      {Phoenix.PubSub, name: CodeMySpec.PubSub},
      {Registry, keys: :unique, name: CodeMySpecCli.Registry},
      CodeMySpec.Sessions.InteractionRegistry,
      {CodeMySpecCli.CliRunner, args}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CodeMySpecCli.Supervisor)
  end

  defp get_cli_args do
    Application.get_env(:code_my_spec_cli, :cli_args) || burrito_args()
  end

  defp burrito_args do
    if System.get_env("__BURRITO_BIN_PATH"), do: Args.get_arguments()
  end

  defp ensure_db_directory do
    db_path = Path.expand("~/.codemyspec/cli.db")
    db_path |> Path.dirname() |> File.mkdir_p!()
  end

  defp ensure_log_directory do
    log_path = Path.expand("~/.codemyspec/cli.log")
    log_path |> Path.dirname() |> File.mkdir_p!()
  end

  defp setup_file_logger do
    # Add the file backend handler dynamically
    {:ok, _} = LoggerBackends.add({LoggerFileBackend, :file_log})

    # Configure the backend with settings from config
    config = Application.get_env(:logger, :file_log, [])

    Logger.configure_backend({LoggerFileBackend, :file_log},
      path: Keyword.get(config, :path, Path.expand("~/.codemyspec/cli.log")),
      level: Keyword.get(config, :level, :debug),
      format: Keyword.get(config, :format, "$time $metadata[$level] $message\n"),
      metadata: Keyword.get(config, :metadata, [:request_id, :mfa])
    )
  end
end
