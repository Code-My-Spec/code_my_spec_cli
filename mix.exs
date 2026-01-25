defmodule CodeMySpecCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :code_my_spec_cli,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger, :ecto, :ecto_sql],
      mod: {CodeMySpecCli.Application, []}
    ]
  end

  defp deps do
    [
      # Core dependency (runtime: false so CLI manages its own supervision tree)
      {:code_my_spec, path: "../code_my_spec", runtime: false},

      # CLI deps
      {:burrito, "~> 1.5"},
      {:optimus, "~> 0.5"},
      {:oauth2, "~> 2.0"},
      {:logger_backends, "~> 1.0"},
      {:logger_file_backend, "~> 0.0.14"},
      {:yaml_elixir, "~> 2.11"},
      {:jason, "~> 1.2"},
      {:file_system, "~> 1.0"},
      {:briefly, "~> 0.5.1"},

      # Test deps
      {:exvcr, "~> 0.15", only: :test}
    ]
  end

  defp releases do
    [
      code_my_spec_cli: [
        applications: [code_my_spec: :load],
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos_m1: [os: :darwin, cpu: :aarch64]
            # macos: [os: :darwin, cpu: :x86_64],
            # linux: [os: :linux, cpu: :x86_64],
            # linux_aarch64: [os: :linux, cpu: :aarch64],
            # windows: [os: :windows, cpu: :x86_64]
          ],
          extra_steps: [
            fetch: [pre: [CodeMySpecCli.Release.PatchLauncherStep]],
            build: [post: [CodeMySpecCli.Release.PackageExtension]]
          ],
          debug: false,
          no_clean: false
        ]
      ]
    ]
  end
end
