defmodule CodeMySpecCli.Config do
  @moduledoc """
  Manages local CLI configuration stored in .code_my_spec/config.yml

  The config file stores:
  - project_id: The ID of the project this directory belongs to (required)
  - module_name: The base module name for the project (e.g., "MyApp")
  - current_user_email: The email of the currently logged-in user (optional)

  User authentication (OAuth tokens) is stored separately in the encrypted database.
  When a user logs in via /login, we store their email here and their tokens in client_users table.
  """

  @config_dir ".code_my_spec"
  @config_file "config.yml"

  @doc """
  Gets the project ID from the local config file.
  Returns {:ok, project_id} or {:error, reason}
  """
  @spec get_project_id(String.t() | nil) :: {:ok, String.t()} | {:error, atom()}
  def get_project_id(working_dir \\ nil) do
    case read_config(working_dir) do
      {:ok, config} ->
        case config["project_id"] do
          nil -> {:error, :project_id_not_set}
          id when is_binary(id) -> {:ok, id}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Sets the project ID in the local config file.
  Creates the config file if it doesn't exist.
  """
  @spec set_project_id(String.t()) :: :ok | {:error, term()}
  def set_project_id(project_id) when is_binary(project_id) do
    config =
      case read_config() do
        {:ok, existing} -> existing
        {:error, _} -> %{}
      end

    updated_config = Map.put(config, "project_id", project_id)
    write_config(updated_config)
  end

  @doc """
  Gets the account ID from the local config file.
  Returns {:ok, account_id} or {:error, reason}
  """
  @spec get_account_id(String.t() | nil) :: {:ok, String.t()} | {:error, atom()}
  def get_account_id(working_dir \\ nil) do
    case read_config(working_dir) do
      {:ok, config} ->
        case config["account_id"] do
          nil -> {:error, :account_id_not_set}
          id when is_binary(id) -> {:ok, id}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Sets the account ID in the local config file.
  Creates the config file if it doesn't exist.
  """
  @spec set_account_id(String.t()) :: :ok | {:error, term()}
  def set_account_id(account_id) when is_binary(account_id) do
    config =
      case read_config() do
        {:ok, existing} -> existing
        {:error, _} -> %{}
      end

    updated_config = Map.put(config, "account_id", account_id)
    write_config(updated_config)
  end

  @doc """
  Gets the module name from the local config file.
  Returns {:ok, module_name} or {:error, reason}
  """
  @spec get_module_name(String.t() | nil) :: {:ok, String.t()} | {:error, atom()}
  def get_module_name(working_dir \\ nil) do
    case read_config(working_dir) do
      {:ok, config} ->
        case config["module_name"] do
          nil -> {:error, :module_name_not_set}
          name when is_binary(name) -> {:ok, name}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Sets the module name in the local config file.
  """
  @spec set_module_name(String.t()) :: :ok | {:error, term()}
  def set_module_name(module_name) when is_binary(module_name) do
    config =
      case read_config() do
        {:ok, existing} -> existing
        {:error, _} -> %{}
      end

    updated_config = Map.put(config, "module_name", module_name)
    write_config(updated_config)
  end

  @doc """
  Gets the current user email from the local config file.
  Returns {:ok, email} or {:error, :not_set} if no user is logged in.
  """
  @spec get_current_user_email(String.t() | nil) :: {:ok, String.t()} | {:error, :not_set}
  def get_current_user_email(working_dir \\ nil) do
    case read_config(working_dir) do
      {:ok, config} ->
        case config["current_user_email"] do
          nil -> {:error, :not_set}
          email when is_binary(email) -> {:ok, email}
        end

      {:error, _} ->
        {:error, :not_set}
    end
  end

  @doc """
  Sets the current user email in the local config file.
  Call this after successful OAuth login.
  """
  @spec set_current_user_email(String.t()) :: :ok | {:error, term()}
  def set_current_user_email(email) when is_binary(email) do
    config =
      case read_config() do
        {:ok, existing} -> existing
        {:error, _} -> %{}
      end

    updated_config = Map.put(config, "current_user_email", email)
    write_config(updated_config)
  end

  @doc """
  Clears the current user email from the config file.
  Call this on logout.
  """
  @spec clear_current_user_email() :: :ok | {:error, term()}
  def clear_current_user_email do
    config =
      case read_config() do
        {:ok, existing} -> existing
        {:error, _} -> %{}
      end

    updated_config = Map.delete(config, "current_user_email")
    write_config(updated_config)
  end

  @doc """
  Initializes the config file with a project ID.
  """
  @spec init(String.t()) :: :ok | {:error, term()}
  def init(project_id) when is_binary(project_id) do
    config = %{
      "project_id" => project_id
    }

    write_config(config)
  end

  @doc """
  Reads the entire config file.
  """
  @spec read_config(String.t() | nil) :: {:ok, map()} | {:error, atom()}
  def read_config(working_dir \\ nil) do
    config_path = get_config_path(working_dir)

    if File.exists?(config_path) do
      case YamlElixir.read_from_file(config_path) do
        {:ok, config} when is_map(config) -> {:ok, config}
        {:ok, nil} -> {:ok, %{}}
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, :config_not_found}
    end
  end

  @doc """
  Writes the config to the file.
  """
  @spec write_config(map()) :: :ok | {:error, term()}
  def write_config(config) when is_map(config) do
    config_dir = get_config_dir()
    config_path = get_config_path()

    # Ensure directory exists
    File.mkdir_p!(config_dir)

    # Convert to YAML manually (simple key-value format)
    yaml =
      config
      |> Enum.map_join("\n", fn {key, value} ->
        # Quote strings if they contain special characters
        formatted_value =
          if is_binary(value) and String.contains?(value, [":", "@"]) do
            "\"#{value}\""
          else
            value
          end

        "#{key}: #{formatted_value}"
      end)
      |> Kernel.<>("\n")

    File.write(config_path, yaml)
  end

  @doc """
  Gets the path to the config directory (project_root/.code_my_spec)
  """
  @spec get_config_dir(String.t() | nil) :: String.t()
  def get_config_dir(working_dir \\ nil) do
    base_dir = working_dir || get_working_dir()
    Path.join(base_dir, @config_dir)
  end

  @doc """
  Gets the working directory from env var, or finds project root by walking up.
  """
  @spec get_working_dir() :: String.t()
  def get_working_dir do
    case System.get_env("CODE_MY_SPEC_WORKING_DIR") do
      nil ->
        case find_project_root() do
          {:ok, root} -> root
          {:error, _} -> File.cwd!()
        end

      dir ->
        dir
    end
  end

  @doc """
  Finds the project root by walking up the directory tree looking for mix.exs.

  Returns {:ok, path} if found, {:error, :project_root_not_found} if not.
  """
  @spec find_project_root(String.t() | nil) :: {:ok, String.t()} | {:error, :project_root_not_found}
  def find_project_root(starting_dir \\ nil) do
    dir = starting_dir || File.cwd!()
    do_find_project_root(dir)
  end

  defp do_find_project_root(dir) do
    cond do
      File.exists?(Path.join(dir, "mix.exs")) ->
        {:ok, dir}

      # Reached filesystem root
      dir == "/" or dir == Path.dirname(dir) ->
        {:error, :project_root_not_found}

      # Walk up
      true ->
        do_find_project_root(Path.dirname(dir))
    end
  end

  @doc """
  Gets the path to the config file (project_root/.code_my_spec/config.yml)
  """
  @spec get_config_path(String.t() | nil) :: String.t()
  def get_config_path(working_dir \\ nil) do
    Path.join(get_config_dir(working_dir), @config_file)
  end
end
