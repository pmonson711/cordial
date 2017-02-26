use Mix.Config

# Configure your database
config :cordial_store, Cordial.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "cordial_db_dev",
  hostname: "localhost",
  pool_size: 10
