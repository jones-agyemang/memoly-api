class Url < SourceIntake
  validates :source_type, inclusion: %w[ url ]

  def source_link
    original_url
  end
end
