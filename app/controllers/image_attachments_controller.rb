class ImageAttachmentsController < ApplicationController
  before_action :doorkeeper_authorize!
  before_action :set_user
  before_action :set_attachable
  before_action :set_active_storage_url_options

  def create
    upload = params.expect(:image)
    content_type = detected_content_type(upload)

    validate_upload!(upload, content_type)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: upload.tempfile,
      filename: upload.original_filename,
      content_type: content_type,
      key: ImageStorageKey.generate,
      identify: false
    )
    @attachable.images.attach(blob)
    attachment = @attachable.images_attachments.find_by!(blob_id: blob.id)

    variants = ImageAttachable::VARIANT_NAMES.index_with do |name|
      attachment.variant(name).processed.url
    end

    render json: {
      id: attachment.id,
      filename: blob.filename.to_s,
      content_type: blob.content_type,
      byte_size: blob.byte_size,
      url: blob.url,
      variants: variants,
      markdown: "![#{markdown_alt_text(blob.filename.to_s)}](#{variants.fetch(:medium)})"
    }, status: :created
  rescue ImageUploadError => error
    render json: { message: error.message }, status: :unprocessable_entity
  rescue StandardError
    if attachment&.persisted?
      attachment.purge
    else
      blob&.purge
    end
    raise
  end

  def destroy
    attachment = @attachable.images_attachments.find(params.expect(:id))
    attachment.purge

    head :no_content
  end

  private

  class ImageUploadError < StandardError; end

  def set_user
    @user = current_user
    requested_user_id = Integer(params.expect(:user_id))

    return if @user.id == requested_user_id

    render json: { message: "Forbidden" }, status: :forbidden
  rescue ArgumentError
    render json: { message: "Forbidden" }, status: :forbidden
  end

  def set_attachable
    @attachable =
      if params[:note_id]
        @user.notes.find(params[:note_id])
      else
        @user.collections.find(params[:collection_id])
      end
  end

  def set_active_storage_url_options
    ActiveStorage::Current.url_options = {
      protocol: request.protocol,
      host: request.host,
      port: request.port
    }
  end

  def detected_content_type(upload)
    Marcel::MimeType.for(upload.tempfile)
  end

  def validate_upload!(upload, content_type)
    extension = File.extname(upload.original_filename.to_s).downcase

    unless ImageAttachable::ALLOWED_CONTENT_TYPES.include?(content_type) &&
        ImageAttachable::ALLOWED_EXTENSIONS.include?(extension)
      raise ImageUploadError, "Only PNG, JPG, JPEG, WebP, and GIF images are allowed"
    end

    if upload.size > ImageAttachable::MAX_IMAGE_SIZE
      raise ImageUploadError, "Image must not exceed 10 MB"
    end
  end

  def markdown_alt_text(filename)
    File.basename(filename, File.extname(filename)).gsub(/[\[\]]/, "").presence || "image"
  end
end
