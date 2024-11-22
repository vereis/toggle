import Config

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Configure your database

# Enable helpful, but potentially expensive runtime checks
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :toggle, Toggle.Repo,
  database: Path.expand("../toggle_test.db", __DIR__),
  pool_size: 5,
  # We don't run a server during test. If one is required,
  # you can enable the server option below.
  pool: Ecto.Adapters.SQL.Sandbox

config :toggle, ToggleWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "B5C3zRsu5o9nmXIDFg7Bz3T/PgSpE2HeQXAOAF9iz0QM1tzGi9lR5xS15eSHrti4",
  server: false
