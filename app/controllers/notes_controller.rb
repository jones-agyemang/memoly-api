class NotesController < ApplicationController
  before_action :set_user
  before_action :set_collection, on: %i[ create index show ]
  before_action :set_note, only: %i[ update destroy ]

  def create
    @note = @user.notes.build **note_params, collection: @collection

    if @note.save
      render :show, status: :created
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def index
    @notes = @collection.default? ? @user.notes.order(updated_at: :desc) : @collection.notes.order(updated_at: :desc)

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
    @user = User.find user_params
  end

  def user_params
    params.expect(:user_id)
  end

  def set_note
    @note = @user.notes.find params[:id]
  end

  def set_collection
    @collection ||= (
      @user.collections.find_by(id: params[:collection_id]) ||
      @user.collections.find_by(label: Collection::DEFAULT_CATEGORY_LABEL)
    )
  end

  def collection_params
    params.permit(:collection_id)
  end

  def note_params
    params.expect(note: [ :raw_content, :source ])
  end
end
