class RawText < SourceIntake
  validates :source_type, inclusion: %w[ raw_text ]
end
