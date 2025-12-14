class QuizzesController < ApplicationController
  # POST /quizzes
  # POST /quizzes.json
  def create
    topic = quiz_params[:topic].presence || due_notes_topic

    if topic.present?
      result = ::CreateQuiz.call topic
      render json: result, status: :created
    else
      render json: { message: "Topic is missing" }, status: :unprocessable_entity
    end
  end

  private

  def quiz_params
    params.permit(:topic, :user_id, :date)
  end

  def due_notes_topic
    return if quiz_params[:user_id].blank?

    notes = DueNotes.call(user_id: quiz_params[:user_id], date: requested_date)
    return if notes.blank?

    topic_segments = notes.map do |collection_label, note_records|
      label = collection_label || "General"
      contents = note_records.map { |note| note.raw_content.presence }.compact
      next if contents.empty?

      "#{label}: #{contents.join('; ')}"
    end.compact

    topic_segments.join("\n").presence
  end

  def requested_date
    value = quiz_params[:date]
    return Time.zone.today if value.blank?

    Time.zone.parse(value).to_date
  rescue ArgumentError, TypeError
    Time.zone.today
  end
end
