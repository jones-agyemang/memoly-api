class User < ApplicationRecord
  has_one :authentication_code
  has_many :notes
  has_many :collections

  validates :email, uniqueness: true
end
