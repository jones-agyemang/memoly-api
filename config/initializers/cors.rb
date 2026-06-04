# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# binding.pry
module OriginHelper
  def fetch_origin
    # allow requests from localhost
    return %r{\Ahttp?://localhost(:\d+)?\z} if Rails.env.local?

    ENV.fetch("APP_URL")
  end
end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    extend OriginHelper
    origins fetch_origin

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true
  end
end
