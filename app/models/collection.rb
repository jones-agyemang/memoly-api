class Collection < ApplicationRecord
  belongs_to :user
  has_many :children, class_name: "Collection", foreign_key: :parent_id, dependent: :destroy
end
