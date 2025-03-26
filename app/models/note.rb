class Note < ApplicationRecord
  has_many :reminders, dependent: :destroy
end
