module ImageAttachable
  extend ActiveSupport::Concern

  MAX_IMAGE_SIZE = 10.megabytes
  ALLOWED_CONTENT_TYPES = %w[image/png image/jpeg image/webp image/gif].freeze
  ALLOWED_EXTENSIONS = %w[.png .jpg .jpeg .webp .gif].freeze
  VARIANT_NAMES = %i[large medium small].freeze

  included do
    has_many_attached :images do |attachable|
      attachable.variant :large, resize_to_limit: [ 1600, 1600 ]
      attachable.variant :medium, resize_to_limit: [ 960, 960 ]
      attachable.variant :small, resize_to_limit: [ 480, 480 ]
    end

    validate :validate_attached_images
  end

  private

  def validate_attached_images
    images.each do |image|
      unless ALLOWED_CONTENT_TYPES.include?(image.content_type)
        errors.add(:images, "must be a PNG, JPG, JPEG, WebP, or GIF")
      end

      unless ALLOWED_EXTENSIONS.include?(File.extname(image.filename.to_s).downcase)
        errors.add(:images, "must use a .png, .jpg, .jpeg, .webp, or .gif extension")
      end

      if image.byte_size > MAX_IMAGE_SIZE
        errors.add(:images, "must not exceed 10 MB")
      end
    end
  end
end
