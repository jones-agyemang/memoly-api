class QuizzesController < ApplicationController
  # POST /quizzes
  # POST /quizzes.json
  def create
    if quiz_params[:topic].presence
      result = ::CreateQuiz.call quiz_params[:topic]
      render json: result, status: :created
    else
      render json: { message: "Topic is missing" }, status: :unprocessable_entity
    end
  end

  private
    def quiz_params
      params.require(:quiz).permit(:topic)
    end
end
