# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :code_hunt,
  ecto_repos: [CodeHunt.Repo]

# Configures the endpoint
config :code_hunt, CodeHuntWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: CodeHuntWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CodeHunt.PubSub,
  live_view: [signing_salt: "5JWEQYhJ"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(css/app.css --bundle --minify --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
