# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :demo,
  ecto_repos: [Demo.Repo]

# Configures the endpoint
config :demo, DemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zlMbr9KIbSMRg9BXFBpsWgVUqeDm09NBI9124BQ8u+2R6ZRk9hcPe9iC4ciM5rZ4",
  render_errors: [view: DemoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Demo.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "NZIguRPO"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix and Ecto
config :phoenix, :json_library, Jason

config :phoenix, :template_engines, leex: Phoenix.LiveView.Engine

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
