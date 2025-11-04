require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MemolyApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # # --- Enable Asset Pipeline in API-only app ---
    # # Serve static files from /public (needed for emails/precompiled assets in production)
    # config.public_file_server.enabled = true

    # # Turn on Sprockets and configure common asset paths
    # config.assets.enabled = true
    # config.assets.quiet = true
    # config.assets.paths << Rails.root.join("app", "assets")
    # config.assets.paths << Rails.root.join("vendor", "assets")
    # # If you keep Action Mailer views with images/CSS under app/assets, they will compile.

    # # Allow generators to create asset files when requested
    # config.generators do |g|
    #   g.assets true
    #   g.stylesheets true
    #   g.javascripts true
    # end
  end
end
