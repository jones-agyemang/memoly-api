# frozen_string_literal: true

module SourceParser
  class Url < Core
    private

    def source_instructions
      # "Use the contents of the following URL(#{source_intake.source}) to generate notes categorised by collection. "
      <<~INSTRUCTIONS.chomp
        Content: #{response_body}.#{' '}
        Use the provided content to generate notes categorised by collection.#{' '}
      INSTRUCTIONS
    end

    def response_body
      Net::HTTP.get(URI(source_intake.source))
    end
  end
end
