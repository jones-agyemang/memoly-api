class User < ApplicationRecord
  has_one :authentication_code
end
