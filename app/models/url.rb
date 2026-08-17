class Url < SourceIntake
  validates :source_type, inclusion: %w[ url ]
end
