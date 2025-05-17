class User < ApplicationRecord
  has_one :authentication_code
  has_many :notes

  validates :email, uniqueness: true
end
