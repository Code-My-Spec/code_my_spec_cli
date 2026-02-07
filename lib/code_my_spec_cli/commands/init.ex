defmodule CodeMySpecCli.Commands.Init do
  @moduledoc """
  Initialize CodeMySpec in the current directory.

  Creates `.code_my_spec/config.yml` by fetching available projects from the server
  and letting the user select one, or by accepting a project ID directly.
  """

  alias CodeMySpecCli.Auth.OAuthClient
  alias CodeMySpecCli.Config

  def run(opts) do
    working_dir = opts[:working_dir]

    case Config.get_project_id(working_dir) do
      {:ok, existing_id} ->
        IO.puts("Already initialized with project ID: #{existing_id}")
        IO.puts("Config file: #{Config.get_config_path(working_dir)}")
        :ok

      {:error, _} ->
        do_init(opts, working_dir)
    end
  end

  defp do_init(opts, working_dir) do
    if opts[:project_id] do
      init_with_project_id(opts[:project_id], working_dir)
    else
      case OAuthClient.get_token() do
        {:ok, token} ->
          fetch_and_select_project(token, working_dir)

        {:error, _} ->
          # Not logged in - create config without project ID
          init_without_project(working_dir)
      end
    end
  end

  defp init_with_project_id(project_id, working_dir) do
    app_name = detect_app_name(working_dir) || "my_app"
    module_name = app_name |> Macro.camelize()

    config = %{
      "project_id" => project_id,
      "module_name" => module_name,
      "name" => app_name
    }

    case Config.write_config(config, working_dir) do
      :ok ->
        IO.puts("Initialized CodeMySpec in #{Config.get_config_path(working_dir)}")
        IO.puts("  project_id: #{project_id}")
        IO.puts("  module_name: #{module_name}")

      {:error, reason} ->
        IO.puts(:stderr, "Failed to write config: #{inspect(reason)}")
        System.halt(1)
    end
  end

  defp init_without_project(working_dir) do
    app_name = detect_app_name(working_dir) || "my_app"
    module_name = app_name |> Macro.camelize()

    config = %{
      "module_name" => module_name,
      "name" => app_name
    }

    case Config.write_config(config, working_dir) do
      :ok ->
        IO.puts("Initialized CodeMySpec in #{Config.get_config_path(working_dir)}")
        IO.puts("  module_name: #{module_name}")
        IO.puts("  name: #{app_name}")
        IO.puts("")
        IO.puts("Note: No project ID configured.")
        IO.puts("To link to a CodeMySpec project:")
        IO.puts("  1. Run 'cms login' to authenticate")
        IO.puts("  2. Run 'cms init' again to select a project")
        IO.puts("  Or manually set project_id in .code_my_spec/config.yml")

      {:error, reason} ->
        IO.puts(:stderr, "Failed to write config: #{inspect(reason)}")
        System.halt(1)
    end
  end

  defp fetch_and_select_project(token, working_dir) do
    server_url = Application.get_env(:code_my_spec, :oauth_base_url, "http://localhost:4000")
    url = "#{server_url}/api/projects"
    headers = [{"authorization", "Bearer #{token}"}]

    case Req.get(url, headers: headers) do
      {:ok, %{status: 200, body: %{"projects" => projects}}} when projects != [] ->
        IO.puts("\nAvailable projects:\n")

        projects
        |> Enum.with_index(1)
        |> Enum.each(fn {p, idx} ->
          IO.puts("  #{idx}. #{p["name"]} (#{p["id"]})")
        end)

        IO.puts("")
        selection = IO.gets("Select project number (or 'n' for new): ") |> String.trim()

        case Integer.parse(selection) do
          {num, ""} when num >= 1 and num <= length(projects) ->
            project = Enum.at(projects, num - 1)
            save_project_config(project, working_dir)

          _ ->
            if selection == "n" do
              IO.puts(:stderr, "Create a new project at https://codemyspec.com first, then run init again.")
              System.halt(1)
            else
              IO.puts(:stderr, "Invalid selection")
              System.halt(1)
            end
        end

      {:ok, %{status: 200, body: %{"projects" => []}}} ->
        IO.puts(:stderr, "No projects found. Create one at https://codemyspec.com first.")
        System.halt(1)

      {:ok, %{status: 401}} ->
        IO.puts(:stderr, "Authentication expired. Run: cms login")
        System.halt(1)

      {:ok, %{status: status, body: body}} ->
        IO.puts(:stderr, "Failed to fetch projects: HTTP #{status} - #{inspect(body)}")
        System.halt(1)

      {:error, reason} ->
        IO.puts(:stderr, "Failed to fetch projects: #{inspect(reason)}")
        System.halt(1)
    end
  end

  defp save_project_config(project, working_dir) do
    config = %{
      "project_id" => project["id"],
      "module_name" => project["module_name"] || detect_app_name(working_dir) |> Macro.camelize(),
      "name" => project["name"],
      "description" => project["description"],
      "code_repo" => project["code_repo"],
      "docs_repo" => project["docs_repo"],
      "client_api_url" => project["client_api_url"]
    }

    case Config.write_config(config, working_dir) do
      :ok ->
        IO.puts("\nInitialized CodeMySpec!")
        IO.puts("  Config: #{Config.get_config_path(working_dir)}")
        IO.puts("  Project: #{project["name"]}")
        IO.puts("  ID: #{project["id"]}")

      {:error, reason} ->
        IO.puts(:stderr, "Failed to write config: #{inspect(reason)}")
        System.halt(1)
    end
  end

  defp detect_app_name(working_dir) do
    base_dir = working_dir || File.cwd!()
    mix_exs = Path.join(base_dir, "mix.exs")

    if File.exists?(mix_exs) do
      case File.read(mix_exs) do
        {:ok, content} ->
          case Regex.run(~r/app:\s*:(\w+)/, content) do
            [_, app_name] -> app_name
            _ -> nil
          end

        _ ->
          nil
      end
    else
      nil
    end
  end
end
