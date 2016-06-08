defmodule Cordial.Mixfile do
  use Mix.Project

  def project do
    [app: :cordial,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     test_coverage: [tool: ExCoveralls],
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Cordial, []},
     applications: applications(Mix.env)]
  end
  defp applications(:test) do
    applications(:all) ++ [:blacksmith]
  end
  defp applications(_all) do
    [:phoenix, :phoenix_html, :cowboy, :logger, :gettext, :phoenix_ecto,
     :postgrex, :ex_admin, :phoenix_pubsub]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
     {:phoenix, "~> 1.2.0-rc.1", override: true},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_ecto, "~> 3.0.0-rc"},
     {:phoenix_pubsub, "~> 1.0.0-rc"},
     {:phoenix_html, "~> 2.5"},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:blacksmith, "~> 0.1"},
     {:ex_admin, github: "smpallen99/ex_admin"},
     {:earmark, "~> 0.2"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:dialyze, "~> 0.2.0", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev},
     {:credo, "~> 0.3", only: [:test, :dev]},
     {:excoveralls, "~> 0.5", only: [:test]}
    ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test.rebuild": ["ecto.drop", "ecto.create", "ecto.migrate", "test"],
     "test": ["ecto.create --quite", "ecto.migrate", "credo --strict --ignore-checks 'moduledoc'", "test"]]
  end
end
