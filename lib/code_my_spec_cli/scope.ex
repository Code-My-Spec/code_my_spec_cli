defmodule CodeMySpecCli.Scope do
  @moduledoc """
  Creates scopes for CLI context.

  This module handles CLI-specific scope creation, loading the project
  and user from local config and database.
  """

  alias CodeMySpec.Users.Scope
  alias CodeMySpec.Projects.Project
  alias CodeMySpec.ClientUsers.ClientUser

  @doc """
  Gets the scope for the current CLI context.

  Loads project from local config and user from database.
  Returns nil if no project is configured.
  """
  @spec get() :: Scope.t() | nil
  def get do
    with {:ok, project_id} <- CodeMySpecCli.Config.get_project_id(),
         %Project{} = project <- CodeMySpec.Repo.get(Project, project_id) do
      %Scope{
        user: get_user(),
        active_account: nil,
        active_account_id: nil,
        active_project: project,
        active_project_id: project.id
      }
    else
      _ -> nil
    end
  end

  @doc """
  Gets the current CLI user.

  Returns the authenticated user from database if logged in,
  otherwise returns a default anonymous user struct.
  """
  @spec get_user() :: ClientUser.t()
  def get_user do
    case CodeMySpecCli.Config.get_current_user_email() do
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
