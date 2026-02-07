defmodule CodeMySpecCli.SlashCommands.SetAgenticMode do
  @moduledoc """
  CLI wrapper for enabling/disabling agentic mode on the project.

  When enabled, the stop hook will run lifecycle checks to keep the agent
  working until all stories are complete with passing BDD specs.

  ## Usage

  Enable agentic mode:
      cms set-agentic-mode --enable

  Disable agentic mode:
      cms set-agentic-mode --disable

  ## Output

  On success: Outputs confirmation message.
  On error: Outputs error message to stderr.
  """

  use CodeMySpecCli.SlashCommands.SlashCommandBehaviour

  alias CodeMySpec.Projects

  def execute(scope, args) do
    require Logger
    Logger.info("[SetAgenticMode CLI] execute called with args: #{inspect(args)}")

    enable = Map.get(args, :enable, false)
    disable = Map.get(args, :disable, false)

    cond do
      enable and disable ->
        IO.puts(:stderr, "Error: Cannot specify both --enable and --disable")
        {:error, "invalid arguments"}

      not enable and not disable ->
        IO.puts(:stderr, "Error: Must specify either --enable or --disable")
        {:error, "invalid arguments"}

      true ->
        set_agentic_mode(scope, enable)
    end
  end

  defp set_agentic_mode(nil, _enable) do
    IO.puts(:stderr, "Error: No project found. Run 'cms init' first.")
    {:error, "no project"}
  end

  defp set_agentic_mode(scope, enable) do
    project = scope.active_project

    if project == nil do
      IO.puts(:stderr, "Error: No active project found.")
      {:error, "no active project"}
    else
      case Projects.update_project(scope, project, %{agentic_mode: enable}) do
        {:ok, updated_project} ->
          status = if updated_project.agentic_mode, do: "enabled", else: "disabled"
          IO.puts("Agentic mode #{status} for project: #{updated_project.name}")

          if enable do
            IO.puts("""

            The agent will now continue working until:
            - All BDD specs pass
            - All stories have BDD specs

            Use /write-bdd-specs to get started with the next story.
            """)
          end

          :ok

        {:error, changeset} ->
          IO.puts(:stderr, "Error updating project: #{inspect(changeset.errors)}")
          {:error, "update failed"}
      end
    end
  end
end
