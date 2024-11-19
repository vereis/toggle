# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  toggle_web: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/toggle_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  toggle_web: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/toggle_web/assets", __DIR__)
  ]

# Configure Mix tasks and generators
config :toggle,
  ecto_repos: [Toggle.Repo]

# Configures the endpoint
config :toggle_web, ToggleWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ToggleWeb.ErrorHTML, json: ToggleWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Toggle.PubSub,
  # Import environment specific config. This must remain at the bottom
  # of this file so it overrides the configuration defined above.
  live_view: [signing_salt: "ux5eChA8"]

config :toggle_web,
  ecto_repos: [Toggle.Repo],
  generators: [context_app: :toggle]

import_config "#{config_env()}.exs"
