class UsersController < ApplicationController
  before_action :set_user

  def index
    @user = User.find_by!(email:)
    render :show, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { "message": "User not found" }, status: :not_found
  end

  private

  def set_user
    @user ||= User.find_by(user_params)
  end

  def user_params
    params.permit(:id)
  end

  def email
    params.expect(:email)
  end
end
