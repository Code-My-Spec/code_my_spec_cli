defmodule CodeMySpecCli.Migrator do
  @moduledoc """
  GenServer that runs migrations synchronously during init.
  Blocks supervision tree startup until migrations complete.
  """

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    run_migrations()
    {:ok, %{}}
  end

  defp run_migrations do
    migrations_path = Application.app_dir(:code_my_spec_cli, "priv/repo/migrations")
    Ecto.Migrator.run(CodeMySpec.Repo, migrations_path, :up, all: true)
  end
end
