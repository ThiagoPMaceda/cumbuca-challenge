# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :cumbuca,
  ecto_repos: [Cumbuca.Repo],
  generators: [binary_id: true, api_prefix: "/api/v1"]

# Configures the endpoint
config :cumbuca, CumbucaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: CumbucaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Cumbuca.PubSub,
  live_view: [signing_salt: "kfvGMQJt"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :cumbuca, Cumbuca.Repo,
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id]

config :cumbuca, Cumbuca.Guardian,
  issuer: "Cumbuca",
  secret_key: "VIYVaRRQX/TsLDYjAFKDUvUj+nBFWR2kiMgsYAprL09t7cB7fMUPgkvh1CZ2Qq6v"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
