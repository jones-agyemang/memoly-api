class NotesController < ApplicationController
  # POST /notes
  def create
    @note = Note.new(note_params)

    if @note.save
      render :show, status: :created
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  # GET /notes
  def index
    @notes = Note.all.order(updated_at: :desc)

    render :index
  end

  private

  def note_params
    params.expect(note: [ :raw_content, :source ])
  end
end
