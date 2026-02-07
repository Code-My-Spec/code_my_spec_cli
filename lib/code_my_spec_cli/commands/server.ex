defmodule CodeMySpecCli.Commands.Server do
  @moduledoc """
  Server management commands for the CodeMySpec local MCP server.

  The server runs as a Bandit HTTP server that Claude Code connects to
  via HTTP/SSE instead of stdio transport, eliminating the 2-3 second
  BEAM cold start on every tool call.

  ## Commands

  - `install` - Install and load the LaunchAgent for auto-start
  - `uninstall` - Unload and remove the LaunchAgent
  - `start` - Start the server manually (if not using LaunchAgent)
  - `stop` - Stop the server
  - `status` - Show server status
  - `run` - Run the server in foreground (used by LaunchAgent)
  """

  require Logger

  @plist_name "com.codemyspec.server"
  @plist_path "~/Library/LaunchAgents/#{@plist_name}.plist"
  @default_port 4001
  @pid_file "~/.codemyspec/server.pid"
  @log_file "/tmp/codemyspec.log"
  @error_log_file "/tmp/codemyspec.error.log"

  def run(action, opts \\ []) do
    case action do
      :install -> install(opts)
      :uninstall -> uninstall(opts)
      :start -> start(opts)
      :stop -> stop(opts)
      :status -> status(opts)
      :run -> run_foreground(opts)
    end
  end

  @doc """
  Install and load the LaunchAgent for auto-start on login.
  """
  def install(_opts) do
    IO.puts("Installing CodeMySpec server LaunchAgent...")

    plist_path = Path.expand(@plist_path)
    plist_dir = Path.dirname(plist_path)

    # Ensure LaunchAgents directory exists
    File.mkdir_p!(plist_dir)

    # Get the path to the codemyspec binary
    binary_path = get_binary_path()

    # Write the plist file
    plist_content = generate_plist(binary_path)
    File.write!(plist_path, plist_content)

    IO.puts("  Wrote: #{plist_path}")

    # Load the LaunchAgent
    case System.cmd("launchctl", ["load", plist_path]) do
      {_, 0} ->
        IO.puts("  Loaded LaunchAgent")
        IO.puts("")
        IO.puts("Server installed and started!")
        IO.puts("  Log: #{@log_file}")
        IO.puts("  Error log: #{@error_log_file}")
        IO.puts("")
        IO.puts("The server will start automatically on login.")
        :ok

      {output, code} ->
        IO.puts(:stderr, "Failed to load LaunchAgent (exit #{code}): #{output}")
        System.halt(1)
    end
  end

  @doc """
  Unload and remove the LaunchAgent.
  """
  def uninstall(_opts) do
    plist_path = Path.expand(@plist_path)

    if File.exists?(plist_path) do
      IO.puts("Uninstalling CodeMySpec server LaunchAgent...")

      # Unload the LaunchAgent
      case System.cmd("launchctl", ["unload", plist_path]) do
        {_, 0} -> IO.puts("  Unloaded LaunchAgent")
        {_, _} -> IO.puts("  LaunchAgent was not loaded")
      end

      # Remove the plist file
      File.rm!(plist_path)
      IO.puts("  Removed: #{plist_path}")
      IO.puts("")
      IO.puts("Server uninstalled.")
    else
      IO.puts("LaunchAgent not installed.")
    end

    :ok
  end

  @doc """
  Start the server manually (if not using LaunchAgent).
  """
  def start(_opts) do
    case check_server_running() do
      {:ok, pid} ->
        IO.puts("Server already running (PID: #{pid})")
        :ok

      {:error, :not_running} ->
        IO.puts("Starting CodeMySpec server...")
        start_server_daemon()
    end
  end

  @doc """
  Stop the server.
  """
  def stop(_opts) do
    case check_server_running() do
      {:ok, pid} ->
        IO.puts("Stopping server (PID: #{pid})...")

        # Send SIGTERM to the process
        case System.cmd("kill", [to_string(pid)]) do
          {_, 0} ->
            # Wait a moment then verify it's stopped
            Process.sleep(500)

            case check_server_running() do
              {:error, :not_running} ->
                clean_pid_file()
                IO.puts("Server stopped.")
                :ok

              {:ok, _} ->
                IO.puts(:stderr, "Server did not stop, sending SIGKILL...")
                System.cmd("kill", ["-9", to_string(pid)])
                clean_pid_file()
                :ok
            end

          {_, _} ->
            IO.puts(:stderr, "Failed to stop server")
            System.halt(1)
        end

      {:error, :not_running} ->
        IO.puts("Server is not running.")
        :ok
    end
  end

  @doc """
  Show server status.
  """
  def status(_opts) do
    port = @default_port

    case check_server_running() do
      {:ok, pid} ->
        IO.puts("Server running")
        IO.puts("  PID: #{pid}")
        IO.puts("  Port: #{port}")
        IO.puts("  URL: http://localhost:#{port}/mcp/architecture")
        :ok

      {:error, :not_running} ->
        # Also check if something is listening on the port
        case check_port_listening(port) do
          true ->
            IO.puts("Server listening on port #{port} (PID file not found)")
            IO.puts("  URL: http://localhost:#{port}/mcp/architecture")

          false ->
            IO.puts("Server not running")
        end

        :ok
    end
  end

  @doc """
  Run the server in foreground (called by LaunchAgent).
  """
  def run_foreground(_opts) do
    Logger.info("[Server] Starting CodeMySpec local server...")

    # Write PID file
    write_pid_file()

    # Start the local server
    case CodeMySpec.LocalServer.start_link(port: @default_port) do
      {:ok, _pid} ->
        Logger.info("[Server] Server started on port #{@default_port}")
        # Keep the process running
        Process.sleep(:infinity)

      {:error, reason} ->
        Logger.error("[Server] Failed to start: #{inspect(reason)}")
        System.halt(1)
    end
  end

  # Private helpers

  defp get_binary_path do
    # In release, use the release binary
    case :init.get_argument(:progname) do
      {:ok, [[progname]]} ->
        to_string(progname)

      _ ->
        # Fallback for development - use mix
        case System.find_executable("codemyspec") do
          nil ->
            IO.puts(:stderr, "Could not find codemyspec binary")
            System.halt(1)

          path ->
            path
        end
    end
  end

  defp generate_plist(binary_path) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Label</key>
        <string>#{@plist_name}</string>
        <key>ProgramArguments</key>
        <array>
            <string>#{binary_path}</string>
            <string>server</string>
            <string>run</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>StandardOutPath</key>
        <string>#{@log_file}</string>
        <key>StandardErrorPath</key>
        <string>#{@error_log_file}</string>
    </dict>
    </plist>
    """
  end

  defp check_server_running do
    pid_path = Path.expand(@pid_file)

    if File.exists?(pid_path) do
      case File.read(pid_path) do
        {:ok, content} ->
          pid = String.trim(content) |> String.to_integer()

          # Check if process is still running
          case System.cmd("kill", ["-0", to_string(pid)], stderr_to_stdout: true) do
            {_, 0} -> {:ok, pid}
            {_, _} -> {:error, :not_running}
          end

        {:error, _} ->
          {:error, :not_running}
      end
    else
      {:error, :not_running}
    end
  end

  defp check_port_listening(port) do
    case System.cmd("lsof", ["-i", ":#{port}"], stderr_to_stdout: true) do
      {_, 0} -> true
      {_, _} -> false
    end
  end

  defp write_pid_file do
    pid_path = Path.expand(@pid_file)
    pid_dir = Path.dirname(pid_path)
    File.mkdir_p!(pid_dir)
    File.write!(pid_path, to_string(System.pid()))
  end

  defp clean_pid_file do
    pid_path = Path.expand(@pid_file)
    File.rm(pid_path)
  end

  defp start_server_daemon do
    binary_path = get_binary_path()

    # Start as detached process
    port =
      Port.open(
        {:spawn_executable, binary_path},
        [
          :binary,
          :exit_status,
          args: ["server", "run"]
        ]
      )

    # Wait a moment for server to start
    Process.sleep(2000)

    case check_server_running() do
      {:ok, pid} ->
        IO.puts("Server started (PID: #{pid})")
        IO.puts("  URL: http://localhost:#{@default_port}/mcp/architecture")
        Port.close(port)
        :ok

      {:error, :not_running} ->
        IO.puts(:stderr, "Failed to start server")
        Port.close(port)
        System.halt(1)
    end
  end
end
