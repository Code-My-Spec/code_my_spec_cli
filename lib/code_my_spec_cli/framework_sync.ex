defmodule CodeMySpecCli.FrameworkSync do
  @moduledoc """
  CLI startup hook that syncs framework files into the current working directory.

  Delegates to `CodeMySpec.FrameworkSync` with `File.cwd!()`.
  """

  def sync do
    CodeMySpec.FrameworkSync.sync(File.cwd!())
  end
end
