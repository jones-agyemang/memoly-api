class QuizzesController < ApplicationController
  before_action :doorkeeper_authorize!

  # POST /quizzes
  # POST /quizzes.json
  def create
    topics = normalized_topics.presence || due_notes_topic

    if topics.present?
      result = ::CreateQuiz.call(topics)
      render json: result, status: :created
    else
      render json: { message: "Topic is missing" }, status: :unprocessable_entity
    end
  end

  private

  def quiz_params
    source = params[:quiz].presence || params
    source.slice(:topic, :user_id, :date).permit(:topic, :user_id, :date, topic: [])
  end

  def normalized_topics
    Array(quiz_params[:topic]).compact_blank
  end

  def due_notes_topic
    return unless current_user

    notes = DueNotes.call(user_id: current_user.id, date: requested_date)
    return if notes.blank?

    notes.flat_map do |collection_label, note_records|
      note_records.filter_map do |note|
        note.raw_content.presence
      end
    end
  end

  def requested_date
    value = quiz_params[:date]
    return Time.zone.today if value.blank?

    Time.zone.parse(value)&.to_date || Time.zone.today
  rescue ArgumentError, TypeError
    Time.zone.today
  end
end
