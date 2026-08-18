class RawText < SourceIntake
  validates :source_type, inclusion: %w[ raw_text ]

  def source_link
    ""
  end
end
