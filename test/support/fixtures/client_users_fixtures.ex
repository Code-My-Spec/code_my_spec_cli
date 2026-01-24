defmodule CodeMySpecCli.ClientUsersFixtures do
  @moduledoc """
  Test helpers for creating client user entities.
  """

  alias CodeMySpec.Accounts.Account
  alias CodeMySpec.Projects.Project
  alias CodeMySpec.Users.Scope

  @doc """
  Generate a client_user.
  """
  def client_user_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        id: System.unique_integer([:positive]),
        email: "client#{System.unique_integer([:positive])}@example.com",
        oauth_expires_at: DateTime.add(DateTime.utc_now(), 86400, :second),
        oauth_refresh_token: "some oauth_refresh_token",
        oauth_token: "some oauth_token"
      })

    {:ok, client_user} = CodeMySpec.ClientUsers.create_client_user(attrs)
    client_user
  end

  @doc """
  Sets up an authenticated client user for testing RemoteClient functionality.
  Creates a ClientUser record with valid OAuth token and sets it as the current user.
  """
  def authenticated_client_user_fixture(attrs \\ %{}) do
    expires_at = DateTime.add(DateTime.utc_now(), 86400, :second)
    token = System.get_env("OAUTH_TOKEN") || "test_token_placeholder"

    default_attrs = %{
      id: System.unique_integer([:positive]),
      email: "authenticated_client#{System.unique_integer([:positive])}@example.com",
      oauth_expires_at: expires_at,
      oauth_refresh_token: "test_refresh_token",
      oauth_token: token
    }

    attrs = Enum.into(attrs, default_attrs)
    {:ok, client_user} = CodeMySpec.ClientUsers.create_client_user(attrs)
    :ok = CodeMySpecCli.Config.set_current_user_email(client_user.email)

    client_user
  end

  @doc """
  Cleans up the authenticated client user config.
  """
  def cleanup_authenticated_client_user(_client_user) do
    CodeMySpecCli.Config.clear_current_user_email()
  end

  @doc """
  Creates a full scope with account and project for CLI testing.
  Uses minimal struct creation since VCR mocks the actual API calls.
  """
  def full_scope_fixture do
    account_id = System.unique_integer([:positive])
    project_id = Ecto.UUID.generate()

    # Create a minimal project in the database
    {:ok, project} =
      CodeMySpec.Repo.insert(%Project{
        id: project_id,
        name: "Test Project",
        module_name: "TestProject",
        account_id: account_id
      })

    # Build scope with the project
    %Scope{
      user: nil,
      active_account: %Account{id: account_id, name: "Test Account"},
      active_account_id: account_id,
      active_project: project,
      active_project_id: project_id
    }
  end
end
