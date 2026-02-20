defmodule CodeMySpecCli.Auth.OAuthClient do
  @moduledoc """
  CLI-specific OAuth2 authentication flow.

  Delegates core token/client management to `CodeMySpec.Auth.OAuthClient`.
  Provides CLI-specific interactive auth flow (browser-based PKCE with local callback server).
  """

  require Logger

  alias CodeMySpec.Auth.OAuthClient, as: Core
  alias CodeMySpecCli.WebServer.Config

  # --- Delegated core functions ---

  defdelegate get_token(), to: Core
  defdelegate authenticated?(), to: Core
  defdelegate get_server_url(), to: Core
  defdelegate get_or_register_client(server_base_url), to: Core
  defdelegate token_expired?(user), to: Core
  defdelegate extract_expires_in(token), to: Core

  # --- CLI-specific auth flow ---

  @doc """
  Authenticate with UI notifications.

  Returns the auth URL that will be opened in the browser.
  """
  def authenticate_with_ui(opts \\ []) do
    server_base_url = opts[:server_url] || Core.get_server_url()
    {:ok, client_id, _client_secret} = Core.get_or_register_client(server_base_url, Config.oauth_callback_url())

    {_code_verifier, code_challenge} = Core.generate_pkce_pair()
    state = Core.generate_state()

    redirect_uri = Config.oauth_callback_url()

    auth_url =
      "#{server_base_url}/oauth/authorize?" <>
        "client_id=#{client_id}" <>
        "&code_challenge=#{code_challenge}" <>
        "&code_challenge_method=S256" <>
        "&redirect_uri=#{URI.encode_www_form(redirect_uri)}" <>
        "&response_type=code" <>
        "&scope=read+write" <>
        "&state=#{state}"

    result = authenticate(opts)

    {auth_url, result}
  end

  @doc """
  Authenticate the user via OAuth2 authorization code flow with PKCE.

  Opens the user's browser and waits for the callback from the local server.
  """
  def authenticate(opts \\ []) do
    server_base_url = opts[:server_url] || Core.get_server_url()

    web_server_pid =
      case CodeMySpecCli.WebServer.start() do
        {:ok, pid} -> pid
        {:error, :eaddrinuse} -> nil
        {:error, reason} -> raise "Failed to start WebServer for OAuth: #{inspect(reason)}"
      end

    try do
      do_authenticate(server_base_url)
    after
      CodeMySpecCli.WebServer.stop(web_server_pid)
    end
  end

  defp do_authenticate(server_base_url) do
    {:ok, client_id, client_secret} = Core.get_or_register_client(server_base_url, Config.oauth_callback_url())

    {code_verifier, code_challenge} = Core.generate_pkce_pair()
    state = Core.generate_state()
    redirect_uri = Config.oauth_callback_url()

    client =
      OAuth2.Client.new(
        strategy: CodeMySpec.Auth.Strategy,
        client_id: client_id,
        client_secret: client_secret,
        site: server_base_url,
        authorize_url: "#{server_base_url}/oauth/authorize",
        token_url: "#{server_base_url}/oauth/token",
        redirect_uri: redirect_uri,
        request_opts: build_httpc_opts(server_base_url)
      )

    auth_url =
      OAuth2.Client.authorize_url!(client,
        scope: "read write",
        code_challenge: code_challenge,
        code_challenge_method: "S256",
        state: state
      )

    Registry.register(CodeMySpecCli.Registry, {:oauth_waiting, state}, nil)

    open_browser(auth_url)

    result =
      receive do
        {:oauth_callback, {:ok, code, ^state}} ->
          case Core.exchange_code_for_token(code, code_verifier, client_id, client_secret, redirect_uri) do
            {:ok, token_data} ->
              with {:ok, %{id: user_id, email: email}} <-
                     Core.fetch_user_info(server_base_url, token_data["access_token"]),
                   {:ok, _client_user} <- Core.save_client_user(user_id, email, token_data),
                   :ok <- CodeMySpecCli.Config.set_current_user_email(email) do
                :ok
              else
                {:error, _reason} -> :ok
              end

              {:ok, token_data}

            {:error, reason} ->
              {:error, reason}
          end

        {:oauth_callback, {:error, error}} ->
          {:error, "OAuth authorization failed: #{error}"}
      after
        120_000 ->
          {:error, "Timeout waiting for authorization"}
      end

    Registry.unregister(CodeMySpecCli.Registry, {:oauth_waiting, state})

    result
  end

  @doc """
  Called by the local server when an OAuth callback is received.
  Notifies the waiting process.
  """
  def handle_callback({:ok, code, state}) do
    case Registry.lookup(CodeMySpecCli.Registry, {:oauth_waiting, state}) do
      [{pid, _}] -> send(pid, {:oauth_callback, {:ok, code, state}})
      [] -> Logger.warning("No process waiting for OAuth callback with state: #{state}")
    end
  end

  def handle_callback({:error, error}) do
    Logger.error("OAuth callback error: #{error}")
  end

  @doc """
  Clear stored credentials and config email.
  """
  def logout do
    result = Core.logout()
    CodeMySpecCli.Config.clear_current_user_email()
    result
  end

  # --- Private helpers ---

  defp open_browser(url) do
    case :os.type() do
      {:unix, :darwin} -> System.cmd("open", [url])
      {:unix, _} -> System.cmd("xdg-open", [url])
      {:win32, _} -> System.cmd("cmd", ["/c", "start", url])
    end
  end

  defp build_httpc_opts(server_url) do
    if String.starts_with?(server_url, "https://localhost") do
      [ssl: [verify: :verify_none]]
    else
      []
    end
  end
end
