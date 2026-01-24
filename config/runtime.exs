import Config

# CLI runtime configuration
# This runs after compilation and before the system starts

# Configure API base URL for remote client
config :code_my_spec,
  api_base_url: System.get_env("CODEMYSPEC_API_URL") || "https://codemyspec.com"
