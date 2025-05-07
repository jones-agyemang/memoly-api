class ExpiredAuthenticationCode < StandardError; end
class AuthenticationController < ApplicationController
  before_action :set_user, only: %i[request_code]

  DEFAULT_CODE_SIZE = 6.freeze

  def request_code
    if request_code_params[:email].empty?
      render json: { "error": "Please supply an email address" }, status: :unprocessable_entity
    else
      create_authentication_code

      SendRequestedCodeMailer
        .with(user_id: @user.id)
        .send_authentication_code.deliver_later

      render json: { "message": "Request code sent to user: #{@user.email}." }, status: :created
    end
  end

  def verify_code
    email = verify_code_params[:email]
    code = verify_code_params[:authentication_code]

    user = User.joins(:authentication_code)
               .find_by!(email:, authentication_code: { code: })

    raise ExpiredAuthenticationCode if user.authentication_code.expires_at.past?

    render json: { message: "Authorized: #{email}." }, status: :created

  rescue ActiveRecord::RecordNotFound, ExpiredAuthenticationCode
    render json: { message: "Invalid user credentials." }, status: :unauthorized
  end

  private

  def request_code_params
    params.permit(:email)
  end

  def verify_code_params
    params.permit(:email, :authentication_code)
  end

  def set_user
    @user = ::User.find_or_create_by(email: request_code_params[:email])
  end

  def create_authentication_code
    attrs = {
      code: generate_authentication_code,
      expires_at: Time.zone.now + 15.minutes
    }

    code = @user.authentication_code || @user.build_authentication_code
    code.assign_attributes attrs
    code.save!
  end

  def generate_authentication_code
    DEFAULT_CODE_SIZE.times.map { SecureRandom.random_number(10) }.join
  end
end
