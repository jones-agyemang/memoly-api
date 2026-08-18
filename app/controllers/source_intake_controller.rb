class SourceIntakeController < ApplicationController
  before_action :doorkeeper_authorize!

  class PdfUploadError < StandardError; end

  def create
    attributes = source_intake_params
    upload = pdf_upload(attributes)
    @source_intake = current_user.source_intakes.build(attributes)
    attach_pdf(upload) if upload

    if @source_intake.save
      SourceParserWorker.perform_async(@source_intake.id)
      render json: @source_intake, methods: :source_type, status: :accepted
    else
      @source_intake.document.purge if @source_intake.is_a?(PdfSource) && @source_intake.document.attached?
      render json: { message: @source_intake.errors.full_messages }, status: :unprocessable_entity
    end
  rescue PdfUploadError => error
    render json: { message: error.message }, status: :unprocessable_entity
  rescue StandardError
    @source_intake&.document&.purge if @source_intake.is_a?(PdfSource) && @source_intake.document.attached?
    raise
  end

  private

  def source_intake_params
    params.permit(:source_type, :source, :public)
  end

  def pdf_upload(attributes)
    return unless attributes[:source_type] == "pdf"

    upload = params[:pdf]
    raise PdfUploadError, "A PDF file is required" unless upload.respond_to?(:tempfile)

    content_type = Marcel::MimeType.for(upload.tempfile)
    extension = File.extname(upload.original_filename.to_s).downcase
    raise PdfUploadError, "Only PDF files are allowed" unless content_type == PdfSource::CONTENT_TYPE && extension == ".pdf"
    raise PdfUploadError, "PDF must not exceed 5 MB" if upload.size > PdfSource::MAX_FILE_SIZE

    attributes[:source] = upload.original_filename
    upload
  end

  def attach_pdf(upload)
    @source_intake.document.attach(
      io: upload.tempfile,
      filename: upload.original_filename,
      content_type: PdfSource::CONTENT_TYPE,
      identify: false
    )
  end
end
