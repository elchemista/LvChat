# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :lv_chat, LvChatWeb.Endpoint,
  url: [host: "localhost"],
  live_view: [
    signing_salt: "M44/HY2YxmcJMW+/swNfVDPq0xmqGJF8"
  ],
  secret_key_base: "IqpY3TodDTocPoA6QAodNhpozcHGZzfZ87/yQX+/jvy5V7S3CWTC9L1RGlbtJ+Ry",
  render_errors: [view: LvChatWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LvChat.PubSub, adapter: Phoenix.PubSub.PG2]

config :oauth2,
  serializers: %{
    "application/json" => Jason
  }

config :lv_chat, :facebook,
  client_id: System.get_env("FACEBOOK_CLIENT_ID"),
  client_secret: System.get_env("FACEBOOK_CLIENT_SECRET"),
  redirect_uri: System.get_env("FACEBOOK_REDIRECT_URI")
  
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
