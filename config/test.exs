use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cordial, Cordial.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
# config :logger, :console, format: "[$level] $message\n"

# Configure your database
config :cordial, Cordial.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "pmonson",
  password: "pmonson",
  database: "cordial_test",
  hostname: if(System.get_env("CI"), do: "postgres", else: "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox
