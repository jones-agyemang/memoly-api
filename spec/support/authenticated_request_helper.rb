module AuthenticatedRequestHelper
  def sign_in_with_encrypted_cookie(user)
    access_token = create(:access_token, user:)

    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookie_jar = ActionDispatch::Cookies::CookieJar.build(request, {})

    cookie_jar.encrypted[:access_token] = {
      value: access_token.token,
      httponly: true,
      secure: false,
      same_site: :none,
      expires: 2.hours.from_now
    }

    cookies[:access_token] = cookie_jar[:access_token]

    access_token
  end
end

RSpec.configure do |config|
  config.include AuthenticatedRequestHelper, type: :request
end
