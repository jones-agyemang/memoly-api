module OauthApplicationHelper
  def create_first_class_oauth_application
    Doorkeeper::Application.find_or_create_by!(name: ENV.fetch("OAUTH_APPLICATION_NAME")) do |app|
      app.redirect_uri = "https://localhost:4000/oauth/callback"
      app.confidential = true
      app.scopes = "users"
    end
  end
end

RSpec.configure do |config|
  config.include OauthApplicationHelper
end
