class UsersController < ApplicationController
  before_action :set_user, only: [ :me ]
  before_action :doorkeeper_authorize!, only: [ :me ]

  def index
    @user = User.find_by!(email:)
    render :show, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { "message": "User not found" }, status: :not_found
  end

  def me
    render :show, status: :ok
  end

  private

  def set_user
    @user ||= current_user
  end

  def email
    params.expect(:email)
  end
end
