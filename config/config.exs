# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :dev_challenge_ryan,
  ecto_repos: [DevChallengeRyan.Repo]

# Configures the endpoint
config :dev_challenge_ryan, DevChallengeRyanWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "qJ02urTpIl8JEDINhJnV/PImbYpOVaEkRnPvNpPb+u1FVR40DlD1r4thiMH+S54u",
  render_errors: [view: DevChallengeRyanWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: DevChallengeRyan.PubSub,
  live_view: [signing_salt: "F6MVgrg6"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
