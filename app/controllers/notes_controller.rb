class NotesController < ApplicationController
  before_action :set_user

  # POST /notes
  def create
    @note = @user.notes.build note_params

    if @note.save
      render :show, status: :created
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  # GET /notes
  def index
    @notes = @user.notes.order(updated_at: :desc)

    render :index
  end

  private

  def set_user
    @user = User.find params[:user_id]
  end

  def user_params
    params.expect(user: [ :id, :email ])
  end

  def note_params
    params.expect(note: [ :raw_content, :source ])
  end
end
