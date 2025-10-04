class NotesController < ApplicationController
  before_action :set_user
  before_action :set_note, only: %i[ update destroy ]

  def create
    @note = @user.notes.build note_params

    if @note.save
      render :show, status: :created
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def index
    @notes = @user.notes.order(updated_at: :desc)

    render :index
  end

  def destroy
    @note.destroy!

    head :no_content
  end

  def update
    if @note.update note_params
      render :show
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find params[:user_id]
  end

  def set_note
    @note = @user.notes.find params[:id]
  end

  def user_params
    params.expect(user: [ :id, :email ])
  end

  def note_params
    params.expect(note: [ :raw_content, :source ])
  end
end
