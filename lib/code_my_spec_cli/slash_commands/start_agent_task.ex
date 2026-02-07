defmodule CodeMySpecCli.SlashCommands.StartAgentTask do
  @moduledoc """
  CLI wrapper for starting agent task sessions.

  Delegates to CodeMySpec.Sessions.AgentTasks.StartAgentTask for core logic,
  adding CLI-specific working directory resolution and output formatting.

  ## Usage

  From CLI:
      cms start-agent-task -e <claude_session_id> -t spec -m MyApp.Accounts

  ## Output

  On success: Outputs the prompt text directly to stdout.
  On error: Outputs error message to stderr.
  """

  use CodeMySpecCli.SlashCommands.SlashCommandBehaviour

  alias CodeMySpec.Sessions.AgentTasks.StartAgentTask, as: DomainStartAgentTask

  def execute(scope, args) do
    require Logger
    Logger.info("[StartAgentTask CLI] execute called with args: #{inspect(Map.keys(args))}")

    # Resolve working_dir - use explicit arg or find project root
    working_dir = Map.get(args, :working_dir) || CodeMySpecCli.Config.get_working_dir()
    args = Map.put(args, :working_dir, working_dir)
    Logger.debug("[StartAgentTask CLI] working_dir: #{working_dir}")

    case DomainStartAgentTask.run(scope, args) do
      {:ok, prompt, sync_result} ->
        Logger.info("[StartAgentTask CLI] Success, prompt length: #{if is_binary(prompt), do: String.length(prompt), else: "NOT A STRING: #{inspect(prompt)}"}")
        output_sync_metrics(sync_result)
        IO.puts(prompt)
        :ok

      {:error, reason} ->
        Logger.error("[StartAgentTask CLI] Error: #{inspect(reason)}")
        IO.puts(:stderr, "Error: #{format_error(reason)}")
        {:error, reason}
    end
  rescue
    error ->
      require Logger
      Logger.error("[StartAgentTask CLI] Exception: #{Exception.message(error)}")
      Logger.error("[StartAgentTask CLI] Stacktrace: #{Exception.format_stacktrace(__STACKTRACE__)}")
      IO.puts(:stderr, "Error: #{Exception.message(error)}")
      {:error, Exception.message(error)}
  end

  defp output_sync_metrics(%{timings: timings}) do
    # Output to stderr so prompt on stdout is clean
    IO.puts(
      :stderr,
      "Sync: contexts=#{timings.contexts_sync_ms}ms requirements=#{timings.requirements_sync_ms}ms total=#{timings.total_ms}ms"
    )
  end

  defp format_error(reason) when is_binary(reason), do: reason
  defp format_error(%Ecto.Changeset{} = changeset), do: inspect(changeset.errors)
  defp format_error(reason), do: inspect(reason)
end
