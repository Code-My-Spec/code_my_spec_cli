defmodule CodeMySpecCli.Scope do
  @moduledoc """
  Creates scopes for CLI context.

  This module handles CLI-specific scope creation, loading the project
  and user from local config and database.
  """

  alias CodeMySpec.ClientUsers.ClientUser
  alias CodeMySpec.Projects.Project
  alias CodeMySpec.Users.Scope

  @doc """
  Gets the scope for the current CLI context.

  Loads project from local config and user from database.
  Returns nil if no project is configured.
  """
  @spec get(String.t() | nil) :: Scope.t() | nil
  def get(working_dir \\ nil) do
    with {:ok, project_id} <- CodeMySpecCli.Config.get_project_id(working_dir),
         {:ok, project} <- get_or_create_project(project_id, working_dir) do
      {account, account_id} = get_account(working_dir)

      %Scope{
        user: get_user(working_dir),
        active_account: account,
        active_account_id: account_id,
        active_project: project,
        active_project_id: project.id
      }
    else
      _ -> nil
    end
  end

  defp get_account(working_dir) do
    case CodeMySpecCli.Config.get_account_id(working_dir) do
      {:ok, account_id} ->
        # CLI doesn't have accounts table - just store the ID from config
        # The account struct will be nil, but account_id is set for scoping
        {nil, account_id}

      {:error, _} ->
        {nil, nil}
    end
  end

  # Gets project from DB, or creates it from config if it doesn't exist
  defp get_or_create_project(project_id, working_dir) do
    case CodeMySpec.Repo.get(Project, project_id) do
      %Project{} = project ->
        {:ok, project}

      nil ->
        # Project not in local DB - create from config
        create_project_from_config(project_id, working_dir)
    end
  end

  defp create_project_from_config(project_id, working_dir) do
    case CodeMySpecCli.Config.read_config(working_dir) do
      {:ok, config} ->
        attrs = %{
          id: project_id,
          name: config["name"] || "Unnamed Project",
          module_name: config["module_name"] || "App",
          description: config["description"],
          account_id: config["account_id"]
        }

        CodeMySpec.Repo.insert(%Project{} |> struct(attrs))

      {:error, _} ->
        {:error, :config_not_found}
    end
  end

  @doc """
  Gets the current CLI user.

  Returns the authenticated user from database if logged in,
  otherwise returns a default anonymous user struct.
  """
  @spec get_user(String.t() | nil) :: ClientUser.t()
  def get_user(working_dir \\ nil) do
    case CodeMySpecCli.Config.get_current_user_email(working_dir) do
      {:ok, email} ->
        CodeMySpec.Repo.get_by(ClientUser, email: email) || default_user()

      {:error, _} ->
        default_user()
    end
  end

  defp default_user do
    %ClientUser{
      id: 0,
      email: "cli@localhost",
      oauth_token: nil,
      oauth_refresh_token: nil,
      oauth_expires_at: nil
    }
  end
end
