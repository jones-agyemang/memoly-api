class CableTokensController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    render json: {
      "token": current_user.signed_id(purpose: :action_cable, expires_in: 10.minutes)
    }
  end
end
