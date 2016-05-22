use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cordial, Cordial.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :cordial, Cordial.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "cordial_test",
  password: "cordial_test",
  database: "cordial_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
