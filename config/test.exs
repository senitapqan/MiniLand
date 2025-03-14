import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :mini_land, MiniLand.Repo,
  username: "postgres",
  hostname: "localhost",
  database: "mini_land_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mini_land, MiniLandWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "FRc/yzftdwSc+wD62AInr25JUXQpLAPseSO1u7nKZoo53l/Jycj9tR5MPd917F7F",
  server: false

# In test we don't send emails
config :mini_land, MiniLand.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

import_config "test.secret.exs"
