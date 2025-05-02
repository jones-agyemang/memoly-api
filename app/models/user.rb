class User < ApplicationRecord
  has_one :authentication_code

  validates :email, uniqueness: true
end
