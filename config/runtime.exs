import Config
import Dotenvy

# CLI runtime configuration
# This runs after compilation and before the system starts

# Load environment variables from .env files
env_dir_prefix = System.get_env("RELEASE_ROOT") || Path.expand("./envs")

source!([
  Path.absname(".env", env_dir_prefix),
  Path.absname("#{config_env()}.env", env_dir_prefix),
  System.get_env()
])

# Configure API base URL for remote client
config :code_my_spec,
  api_base_url: env!("API_BASE_URL", :string, "https://codemyspec.com"),
  oauth_base_url: env!("OAUTH_BASE_URL", :string, "https://codemyspec.com")
