class CollectionsController < ApplicationController
  before_action :set_collection, only: %i[ show update destroy ]

  # GET /collections
  # GET /collections.json
  def index
    @collections = Collection.all
  end

  # GET /collections/1
  # GET /collections/1.json
  def show
  end

  # POST /collections
  # POST /collections.json
  def create
    @collection = Collection.new(collection_params)

    if @collection.save
      render :show, status: :created, location: @collection
    else
      render json: @collection.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /collections/1
  # PATCH/PUT /collections/1.json
  def update
    if @collection.update(collection_params)
      render :show, status: :ok, location: @collection
    else
      render json: @collection.errors, status: :unprocessable_entity
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.json
  def destroy
    @collection.destroy!
  end

  private
    def set_collection
      @collection = Collection.find(params.expect(:id))
    end

    def collection_params
      params.expect(collection: [ :user_id, :label, :slug, :path, :parent_id, :position ])
    end
end
