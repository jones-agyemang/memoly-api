# frozen_string_literal: true

module SourceParser
  class RawText < Core
    private

    def source_instructions
      <<~INSTRUCTIONS.chomp
        Content: #{source_intake.source}.#{' '}
        Use the provided content to generate notes categorised by collection.#{' '}
      INSTRUCTIONS
    end
  end
end
