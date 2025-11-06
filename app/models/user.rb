class User < ApplicationRecord
  has_one :authentication_code
  has_many :notes
  has_many :collections

  validates :email, uniqueness: true

  after_save :create_default_collection

  private

  def create_default_collection
    collections.create(label: Collection::DEFAULT_CATEGORY_LABEL)
  end
end
