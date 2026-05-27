class QuizzesController < ApplicationController
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
    return if quiz_params[:user_id].blank?

    notes = DueNotes.call(user_id: quiz_params[:user_id], date: requested_date)
    return if notes.blank?

    topic_segments = notes.map do |collection_label, note_records|
      label = collection_label || "General"
      contents = note_records.map { |note| note.raw_content.presence }.compact
      next if contents.empty?

      "#{label}: #{contents.join('; ')}"
    end.compact

    topic_segments
  end

  def requested_date
    value = quiz_params[:date]
    return Time.zone.today if value.blank?

    Time.zone.parse(value)&.to_date || Time.zone.today
  rescue ArgumentError, TypeError
    Time.zone.today
  end
end
