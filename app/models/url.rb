class Url < SourceIntake
  validates :source_type, inclusion: %w[ url ], url: true

  def source_link
    original_url
  end
end
