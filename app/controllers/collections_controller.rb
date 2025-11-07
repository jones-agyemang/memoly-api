class CollectionsController < ApplicationController
  before_action :set_user
  before_action :set_collection, only: %i[ update ]

  def index
    @collections = @user.collections.top_level.order(:position)

    render :index, status: :ok, format: [ :json ]
  end

  def show
  end

  def create
    @collection = @user.collections.build collection_params

    if @collection.save
      render :show, status: :created, formats: [ :json ]
    else
      render json: @collection.errors, status: :unprocessable_entity
    end
  end

  def update
    if @collection.update collection_params
      render :show, status: :ok, formats: [ :json ]
    else
      render json: @collection.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(user_id_param) || User.find_by(email: user_params)
  end

  def set_collection
    @collection = @user.collections.find(params.expect(:id))
  end

  def user_id_param
    params.expect(:user_id)
  end

  def user_params
    params.expect(:user)
  end

  def collection_params
    params.expect(collection: [ :label, :parent_id, :position ])
  end
end
