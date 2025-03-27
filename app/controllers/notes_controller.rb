class NotesController < ApplicationController
  DEFAULT_INTERVALS = [ 1, 3, 7, 14, 20 ] # DAYS

  # POST /notes
  def create
    @note = Note.new(note_params)

    if @note.save
      generate_spaced_reminders(@note)
      render :show, status: :created
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  private

  def note_params
    params.expect(note: [ :raw_content, :source ])
  end

  def generate_spaced_reminders(note)
    DEFAULT_INTERVALS.each do |interval|
      note.reminders.build(due_date: Time.zone.now + interval.days)
    end
  end
end
