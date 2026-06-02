class ApplicationController < ActionController::API
  include ActionController::Cookies

  before_action :set_authorization_header_from_cookie

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

  def set_authorization_header_from_cookie
    access_token = cookies.encrypted[:access_token]
    return if access_token.blank?

    request.headers["Authorization"] ||= "Bearer #{access_token}"
  end
end
