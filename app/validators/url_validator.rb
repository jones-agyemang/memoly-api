class UrlValidator < ActiveModel::EachValidator
  PERMITTED_PROTOCOLS = %w[http https].freeze

  def validate_each(record, attribute, value)
    parsed_uri = URI.parse(record.source)
    protocol = parsed_uri.scheme

    unless PERMITTED_PROTOCOLS.include?(protocol)
      record.errors.add attribute, "protocol '#{protocol}' is not permitted"
    end

    unless reachable?(parsed_uri)
      record.errors.add attribute, "is unreachable"
    end
  end

  private

  def reachable?(parsed_uri)
    response = Net::HTTP.get_response(parsed_uri)
    Integer(response.code) < 400
  rescue ArgumentError, SocketError
    false
  end
end
