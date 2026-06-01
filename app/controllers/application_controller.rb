class ApplicationController < ActionController::API
  include ActionController::Cookies

  private

  def current_user
    return unless doorkeeper_token

    @current_user ||= User.find(doorkeeper_token.resource_owner_id)
  end

  def oauth_application
    @oauth_application ||= FirstClassOauthApplication.call
  end

  def issue_token(owner:)
    Doorkeeper::AccessToken.create!(
      resource_owner_id: owner.id,
      application_id: oauth_application.id,
      expires_in: 1.weeks,
      scopes: "users"
    )
  end
end
