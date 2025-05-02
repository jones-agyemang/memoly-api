class AuthenticationController < ApplicationController
  before_action :set_user

  def request_code
    if auth_credentials[:email].empty?
      render json: { "error": "Please supply an email address" }, status: :unprocessable_entity
    else
      create_authentication_code

      SendRequestedCodeMailer
        .with(user_id: @user.id)
        .send_authentication_code.deliver_later

      render json: { "message": "Request code sent to user: #{@user.email}" }, status: :created
      # create user (if user does not exist)
      # generate response code
      # associate response code to user
      # send auth-code to user via email
    end
  end

  private

  def auth_credentials
    params.permit(:email)
  end

  def set_user
    @user = ::User.find_or_create_by(email: auth_credentials[:email])
  end

  def create_authentication_code
    attrs = {
      code: generate_authentication_code,
      expires_at: Time.zone.now + 15.minutes
    }

    @user.create_authentication_code! attrs
  end

  def generate_authentication_code
    123456
  end
end
