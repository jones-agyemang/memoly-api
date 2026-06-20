class User < ApplicationRecord
  has_one :authentication_code
  has_many :notes
  has_many :collections
  has_many :source_intakes

  has_many :access_grants, class_name: "Doorkeeper::AccessGrant", foreign_key: :resource_owner_id, dependent: :delete_all
  has_many :access_tokens, class_name: "Doorkeeper::AccessToken", foreign_key: :resource_owner_id, dependent: :delete_all

  validates :email, uniqueness: true

  after_save :create_default_collection

  private

  def create_default_collection
    collections.create(label: Collection::DEFAULT_CATEGORY_LABEL)
  end
end
