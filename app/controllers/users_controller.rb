class UsersController < ApplicationController
  def index
    @user = User.find_by!(email:)
    render :show, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { "message": "User not found" }, status: :not_found
  end

  private

  def email
    params.expect(:email)
  end
end
