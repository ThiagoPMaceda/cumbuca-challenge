import Config

config :cumbuca, Cumbuca.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "cumbuca_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :cumbuca, CumbucaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "90DvqAJQugCgFm6UpjlMRKNd0HGA9P8mffPxxU+GS6Mwxw/g0CvBlXo8OOsvgD1/",
  server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

# Speed up Argon2 in tests
config :argon2_elixir,
  t_cost: 1,
  m_cost: 8
