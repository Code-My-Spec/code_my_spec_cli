defmodule CodeMySpecCli.SlashCommands.Sync do
  @moduledoc """
  Sync project components and regenerate architecture views.

  Use before architecture design, after git pulls, or when views seem stale.

  ## Usage

  From CLI:
      cms sync -w /path/to/project

  ## Output

  On success: Outputs sync summary to stdout.
  On error: Outputs error message to stderr.
  """

  require Logger

  use CodeMySpecCli.SlashCommands.SlashCommandBehaviour

  alias CodeMySpec.ProjectSync.Sync
  alias CodeMySpec.Requirements

  def execute(scope, args) do
    working_dir = Map.get(args, :working_dir)

    with {:ok, _scope} <- validate_scope(scope),
         {:ok, sync_result} <- sync_project(scope, base_dir: working_dir) do
      output_sync_result(sync_result)
      :ok
    else
      {:error, reason} ->
        IO.puts(:stderr, "Error: #{format_error(reason)}")
        {:error, reason}
    end
  rescue
    error ->
      IO.puts(:stderr, "Error: #{Exception.message(error)}")
      {:error, Exception.message(error)}
  end

  defp validate_scope(nil) do
    {:error,
     "No project configured. Run the CLI in a directory with .code_my_spec/config.yml or run /init first."}
  end

  defp validate_scope(scope), do: {:ok, scope}

  defp sync_project(scope, opts) do
    # Clear all requirements before resyncing
    Requirements.clear_all_project_requirements(scope)

    case Sync.sync_all(scope, opts) do
      {:ok, result} ->
        {:ok, result}

      {:error, reason} ->
        {:error, "Sync failed: #{inspect(reason)}"}
    end
  end

  defp output_sync_result(result) do
    %{
      contexts: contexts,
      requirements_updated: requirements_updated,
      architecture_views: architecture_views,
      timings: timings
    } = result

    IO.puts("## Sync Complete")
    IO.puts("")
    IO.puts("### Components")
    IO.puts("- Total: #{length(contexts)}")
    IO.puts("")
    IO.puts("### Requirements")
    IO.puts("- Updated: #{requirements_updated}")
    IO.puts("")
    IO.puts("### Architecture Views")

    if Enum.empty?(architecture_views) do
      IO.puts("- No views generated")
    else
      Enum.each(architecture_views, fn path ->
        IO.puts("- #{path}")
      end)
    end

    IO.puts("")
    IO.puts("### Timing")
    IO.puts("- Components: #{timings.contexts_sync_ms}ms")
    IO.puts("- Requirements: #{timings.requirements_sync_ms}ms")
    IO.puts("- Architecture: #{timings.architecture_ms}ms")
    IO.puts("- Total: #{timings.total_ms}ms")
  end

  defp format_error(reason) when is_binary(reason), do: reason
  defp format_error(%Ecto.Changeset{} = changeset), do: inspect(changeset.errors)
  defp format_error(reason), do: inspect(reason)
end
