class QuizzesController < ApplicationController
  # POST /quizzes
  # POST /quizzes.json
  def create
    @quiz = Quiz.new(quiz_params)

    if @quiz.save
      render :show, status: :created, location: @quiz
    else
      render json: @quiz.errors, status: :unprocessable_entity
    end
  end

  private
    def set_quiz
      @quiz = Quiz.find(params.expect(:id))
    end

    def quiz_params
      params.permit(
        :topic,
        questions_attributes: [
          :raw_content,
          :answer,
          :explanation,
          choices: []
        ]
      )
    end
end
