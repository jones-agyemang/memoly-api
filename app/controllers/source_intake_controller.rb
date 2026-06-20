class SourceIntakeController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    @source_intake = current_user.source_intakes.build(source_intake_params)

    if @source_intake.save
      render json: @source_intake, status: :ok
    else
      render json: { message: @source_intake.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def source_intake_params
    source_type, source, user_id = params.expect(:source_type, :source, :user_id)

    { source_type:, source:, user_id: }
  end
end
