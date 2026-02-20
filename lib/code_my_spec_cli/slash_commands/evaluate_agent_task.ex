defmodule CodeMySpecCli.SlashCommands.EvaluateAgentTask do
  @moduledoc """
  CLI wrapper for evaluating agent task sessions.

  Delegates to CodeMySpec.AgentTasks.EvaluateAgentTask for core logic,
  adding CLI-specific output formatting.

  ## Usage

  Typically called by the Stop hook after an agent task session completes.

  ## Output (JSON for hook decision control)

  Outputs JSON to stdout for Claude Code hook protocol:
  - If valid: `{}` (empty map allows Claude to stop), marks session complete
  - If invalid: `{"decision": "block", "reason": "<feedback>"}` (blocks Claude from stopping)
  - If error: `{}` (allows Claude to stop), error message to stderr
  """

  use CodeMySpecCli.SlashCommands.SlashCommandBehaviour

  alias CodeMySpec.AgentTasks.EvaluateAgentTask, as: DomainEvaluate

  @doc """
  Run evaluation and return the result map for hook output.
  """
  def run(scope, args) do
    # Ensure working_dir is set, falling back to config
    working_dir = Map.get(args, :working_dir) || CodeMySpecCli.Config.get_working_dir()
    args = Map.put(args, :working_dir, working_dir)

    # Delegate to domain module
    result = DomainEvaluate.run(scope, args)

    # Add CLI-specific stderr output for certain results
    add_cli_output(result)

    result
  end

  @doc """
  Execute evaluation with IO output. Legacy interface for direct CLI usage.
  """
  def execute(scope, args) do
    result = run(scope, args)
    IO.puts(Jason.encode!(result))
    :ok
  end

  defp add_cli_output(%{} = result) when map_size(result) == 0 do
    # Empty result typically means success or session already closed
    # Output is already handled by domain module's logger
    :ok
  end

  defp add_cli_output(%{"decision" => "block", "reason" => reason}) do
    IO.puts(:stderr, "Validation blocked: #{reason}")
  end

  defp add_cli_output(_result), do: :ok
end
