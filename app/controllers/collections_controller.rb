class CollectionsController < ApplicationController
  before_action :set_user, only: [ :create ]

  def show
  end

  def create
    @collection = @user.collections.build collection_params

    if @collection.save
      render :show, status: :created, location: @collection, formats: [ :json ]
    else
      render json: @collection.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by(email: user_params)
  end

  def user_params
    params.expect(:user)
  end

  def collection_params
    params.expect(collection: [ :label, :parent_id, :position ])
  end
end
