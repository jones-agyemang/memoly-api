class NotesController < ApplicationController
  before_action :doorkeeper_authorize!
  before_action :set_user
  before_action :set_collection, on: %i[ create index show ]
  before_action :set_note, only: %i[ update destroy ]

  include Pagy::Method

  def create
    @note = @user.notes.build(**note_params, collection: @collection)

    if @note.save
      render :show, status: :created
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def index
    notes = @collection.default? ? @user.notes : @collection.notes
    set = notes.order(updated_at: :desc)

    @pagy, @records = pagy(:keyset, set)
    @count = set.size

    render :index
  end

  def destroy
    @note.destroy!

    head :no_content
  end

  def update
    if @note.update note_update_params
      render :show
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user ||= current_user

    return if ids_match?

    render json: { message: "Forbidden" }, status: :forbidden
  end

  def ids_match?
    @user.id == Integer(params.expect(:user_id))
  rescue ArgumentError
    false
  end

  def set_note
    @note = @user.notes.find params[:id]
  end

  def set_collection
    @collection ||= (get_collection || default_collection)
  rescue ActionController::ParameterMissing
    @collection ||= default_collection
  end

  def get_collection
    @user.collections.find_by(id: collection_params[:collection_id])
  end

  def default_collection
    @user.collections.find_by(label: Collection::DEFAULT_CATEGORY_LABEL)
  end

  def collection_params
    params.require(:note).permit(:collection_id)
  end

  def note_params
    params.expect(note: [ :raw_content, :source, :public ])
  end

  def note_update_params
    params.expect(note: [ :raw_content, :source, :collection_id, :public ]).tap do |attributes|
      collection_id = attributes[:collection_id]

      if collection_id.blank?
        attributes.delete(:collection_id)
        next
      end

      attributes[:collection_id] = @user.collections.find(collection_id).id
    end
  end
end
