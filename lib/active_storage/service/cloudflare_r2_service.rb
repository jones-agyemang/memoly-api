# frozen_string_literal: true

require "active_storage/service/s3_service"

module ActiveStorage
  class Service::CloudflareR2Service < Service::S3Service
    def initialize(host:, public: true, **options)
      @public_host = host.delete_suffix("/")

      # R2 exposes public objects through the configured domain but does not
      # support S3 object ACLs, so uploads must not include `public-read`.
      super(public: false, **options)
      upload_options.delete(:acl)
    end

    def public?
      true
    end

    private

    def public_url(key, **)
      "#{@public_host}/#{key}"
    end
  end
end
