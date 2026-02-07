defmodule CodeMySpecCli.Cli do
  @moduledoc """
  CLI argument parser using Optimus.

  Defines all commands and routes them to appropriate handlers.
  """

  def run(argv) do
    # Strip leading "--" if present (Burrito passes args as "-extra -- args..."
    # to prevent Elixir from interpreting them as script files)
    argv =
      case argv do
        ["--" | rest] -> rest
        other -> other
      end

    # If no arguments provided, show help
    if argv == [] do
      run(["--help"])
    else
      optimus =
        Optimus.new!(
          name: "codemyspec",
          description: "AI-powered Phoenix code generation with proper architecture",
          version: "0.1.0",
          author: "CodeMySpec Team",
          about: "Generate production-quality Phoenix code using Claude Code orchestration",
          allow_unknown_args: false,
          parse_double_dash: true,
          options: [
            working_dir: [
              value_name: "WORKING_DIR",
              short: "-w",
              long: "--working-dir",
              help: "Project working directory (defaults to current directory)",
              required: false,
              parser: :string,
              global: true
            ]
          ],
          subcommands: [
            login: [
              name: "login",
              about: "Authenticate with the CodeMySpec server via OAuth2"
            ],
            logout: [
              name: "logout",
              about: "Clear stored authentication credentials"
            ],
            whoami: [
              name: "whoami",
              about: "Show current authenticated user (triggers token refresh if expired)"
            ],
            init: [
              name: "init",
              about: "Initialize CodeMySpec in a directory (creates .code_my_spec/config.yml)",
              options: [
                project_id: [
                  value_name: "PROJECT_ID",
                  short: "-p",
                  long: "--project-id",
                  help: "Project ID from the CodeMySpec server (if known)",
                  required: false,
                  parser: :string
                ]
              ]
            ],
            mcp: [
              name: "mcp",
              about: "Start MCP server with stdio transport (for Claude Code plugin integration)"
            ],
            server: [
              name: "server",
              about: "Manage the CodeMySpec HTTP server for local MCP connections",
              args: [
                action: [
                  value_name: "ACTION",
                  help: "Action: install, uninstall, start, stop, status, run",
                  required: true,
                  parser: fn s ->
                    case s do
                      "install" -> {:ok, :install}
                      "uninstall" -> {:ok, :uninstall}
                      "start" -> {:ok, :start}
                      "stop" -> {:ok, :stop}
                      "status" -> {:ok, :status}
                      "run" -> {:ok, :run}
                      _ -> {:error, "Invalid action: #{s}. Must be one of: install, uninstall, start, stop, status, run"}
                    end
                  end
                ]
              ]
            ],
            sync: [
              name: "sync",
              about: "Sync project components and regenerate architecture views"
            ],
            set_agentic_mode: [
              name: "set-agentic-mode",
              about: "Enable or disable agentic mode for continuous project work",
              flags: [
                enable: [
                  short: "-e",
                  long: "--enable",
                  help: "Enable agentic mode"
                ],
                disable: [
                  short: "-d",
                  long: "--disable",
                  help: "Disable agentic mode"
                ]
              ]
            ]
          ]
        )

      # Use parse/2 instead of parse!/2 to handle --help and --version gracefully
      # parse/2 returns {:ok, subcommand_path, parse_result} on success
      case Optimus.parse(optimus, argv) do
        {:ok, subcommand_path, parse_result} ->
          execute({subcommand_path, parse_result})

        {:error, errors} ->
          # Optimus returns errors for invalid args
          Enum.each(errors, &IO.puts(:stderr, &1))
          System.halt(1)

        :help ->
          # parse/2 doesn't print help, we need to do it manually
          IO.puts(Optimus.help(optimus))

        :version ->
          # Print version info
          IO.puts("codemyspec version 0.1.0")
      end
    end
  end

  defp run_login do
    alias CodeMySpecCli.Auth.OAuthClient

    IO.puts("Opening browser for authentication...")
    IO.puts("Waiting for OAuth callback...")

    case OAuthClient.authenticate() do
      {:ok, _token_data} ->
        IO.puts("Successfully authenticated!")

      {:error, reason} ->
        IO.puts(:stderr, "Authentication failed: #{reason}")
        System.halt(1)
    end
  end

  defp run_logout do
    alias CodeMySpecCli.Auth.OAuthClient

    case OAuthClient.logout() do
      :ok ->
        IO.puts("Successfully logged out.")
    end
  end

  defp run_whoami do
    alias CodeMySpecCli.Auth.OAuthClient

    IO.puts("Checking authentication (will refresh token if expired)...")

    case OAuthClient.get_token() do
      {:ok, _token} ->
        case CodeMySpecCli.Config.get_current_user_email() do
          {:ok, email} ->
            IO.puts("Authenticated as: #{email}")

          {:error, _} ->
            IO.puts("Authenticated (but no email stored)")
        end

      {:error, :not_authenticated} ->
        IO.puts(:stderr, "Not authenticated. Run: mix cli login")
        System.halt(1)

      {:error, :needs_authentication} ->
        IO.puts(:stderr, "Token expired and refresh failed. Run: mix cli login")
        System.halt(1)
    end
  end

  defp run_mcp_server(opts) do
    require Logger

    Logger.info("[MCP] Starting MCP server...")

    # Store the project working directory for MCP tools to use
    # This is where Claude Code is running, not where the CLI binary lives
    working_dir = opts[:working_dir] || File.cwd!()
    Application.put_env(:code_my_spec, :mcp_working_dir, working_dir)
    Logger.info("[MCP] Working directory: #{working_dir}")

    # Set up scope resolver for STDIO transport (no plug to provide scope)
    # Use a closure to capture working_dir so scope loads config from the right directory
    Application.put_env(:code_my_spec, :scope_resolver, fn ->
      CodeMySpecCli.Scope.get(working_dir)
    end)

    try do
      Logger.debug("[MCP] Checking Hermes.Server.Registry...")
      registry_running = Process.whereis(Hermes.Server.Registry)
      Logger.debug("[MCP] Registry: #{inspect(registry_running)}")

      # CLI application already started Vault, Repo, PubSub via application.ex
      # Just need to start Hermes registry and the MCP server
      children =
        if registry_running do
          Logger.debug("[MCP] Registry already running, skipping...")
          [{CodeMySpec.McpServers.ArchitectureServer, transport: :stdio}]
        else
          Logger.debug("[MCP] Starting Hermes.Server.Registry...")

          [
            Hermes.Server.Registry,
            {CodeMySpec.McpServers.ArchitectureServer, transport: :stdio}
          ]
        end

      opts = [strategy: :one_for_one, name: CodeMySpec.MCP.Supervisor]
      Logger.debug("[MCP] Starting supervisor...")

      case Supervisor.start_link(children, opts) do
        {:ok, pid} ->
          Logger.info("[MCP] Supervisor started: #{inspect(pid)}")
          Logger.info("[MCP] MCP server ready, waiting for requests...")
          # Keep the process running indefinitely to handle MCP requests
          Process.sleep(:infinity)

        {:error, reason} ->
          Logger.error("[MCP] FAILED to start supervisor: #{inspect(reason)}")
          System.halt(1)
      end
    rescue
      e ->
        Logger.error(
          "[MCP] EXCEPTION: #{Exception.message(e)}\n#{Exception.format_stacktrace(__STACKTRACE__)}"
        )

        reraise e, __STACKTRACE__
    catch
      kind, reason ->
        Logger.error("[MCP] CAUGHT #{kind}: #{inspect(reason)}")
        :erlang.raise(kind, reason, __STACKTRACE__)
    end
  end

  defp execute(parsed) do
    case parsed do
      {[:login], _} ->
        run_login()

      {[:logout], _} ->
        run_logout()

      {[:whoami], _} ->
        run_whoami()

      {[:init], %{options: opts}} ->
        CodeMySpecCli.Commands.Init.run(opts)

      {[:mcp], %{options: opts}} ->
        run_mcp_server(opts)

      {[:server], %{args: %{action: action}, options: opts}} ->
        CodeMySpecCli.Commands.Server.run(action, opts)

      {[:sync], %{options: opts}} ->
        CodeMySpecCli.SlashCommands.Sync.run(opts)

      {[:set_agentic_mode], %{options: opts, flags: flags}} ->
        CodeMySpecCli.SlashCommands.SetAgenticMode.run(Map.merge(opts, flags))

      _ ->
        # No subcommand - show help
        run(["--help"])
    end
  end
end
