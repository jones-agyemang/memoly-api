class SourceIntake < ApplicationRecord
  belongs_to :user

  validates :source_type, :source, presence: true
  validates :source_type, inclusion: %w[ url ]
end
