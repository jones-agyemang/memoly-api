class PdfSource < SourceIntake
  MAX_FILE_SIZE = 5.megabytes
  CONTENT_TYPE = "application/pdf"

  has_one_attached :document

  validates :source_type, inclusion: %w[ pdf ]
  validate :document_is_attached
  validate :document_is_a_pdf
  validate :document_is_within_size_limit

  def source_link
    source
  end

  private

  def document_is_attached
    errors.add(:document, "must be attached") unless document.attached?
  end

  def document_is_a_pdf
    return unless document.attached?
    return if document.blob.content_type == CONTENT_TYPE

    errors.add(:document, "must be a PDF")
  end

  def document_is_within_size_limit
    return unless document.attached?
    return if document.blob.byte_size <= MAX_FILE_SIZE

    errors.add(:document, "must not exceed 5 MB")
  end
end
