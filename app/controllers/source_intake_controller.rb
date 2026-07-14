class SourceIntakeController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    @source_intake = current_user.source_intakes.build(source_intake_params)

    if @source_intake.save
      SourceParserWorker.perform_async(@source_intake.id)
      render json: @source_intake, status: :accepted
    else
      render json: { message: @source_intake.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def source_intake_params
    params.permit(:source_type, :source, :public)
  end
end
