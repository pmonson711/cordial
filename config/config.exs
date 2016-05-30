# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :cordial, Cordial.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "pmlJDA0rhxRkXmplf16Mg2i/nHXVcOKOk2Dd+n3m/CYWZ/60YQr2dYqCBbiadWos",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Cordial.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :cordial, ecto_repos: [Cordial.Repo]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :xain, :after_callback, {Phoenix.HTML, :raw}

config :ex_admin,
  repo: Cordial.Repo,
  module: Cordial,
  modules: [
    Cordial.ExAdmin.Dashboard,
    Cordial.ExAdmin.Rsc,
    Cordial.ExAdmin.Identity,
    Cordial.ExAdmin.IdentityType,
    Cordial.ExAdmin.Category,
    Cordial.ExAdmin.Edge,
  ]
