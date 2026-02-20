defmodule CodeMySpecCli.Auth.Strategy do
  @moduledoc """
  Deprecated: use `CodeMySpec.Auth.Strategy` instead.

  This module exists for backwards compatibility.
  """
  defdelegate authorize_url(client, params), to: CodeMySpec.Auth.Strategy
  defdelegate get_token(client, params, headers), to: CodeMySpec.Auth.Strategy
end
