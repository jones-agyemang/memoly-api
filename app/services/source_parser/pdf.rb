# frozen_string_literal: true

require "base64"

module SourceParser
  class Pdf < Core
    private

    def response_input
      [
        {
          role: "system",
          content: [ { type: "input_text", text: meta_prompt } ]
        },
        {
          role: "user",
          content: [
            {
              type: "input_file",
              filename: source_intake.source,
              file_data: encoded_document
            },
            { type: "input_text", text: prompt }
          ]
        }
      ]
    end

    def source_instructions
      "Use the attached PDF (#{source_intake.source}) to generate notes categorised by collection. "
    end

    def encoded_document
      encoded = Base64.strict_encode64(source_intake.document.download)
      "data:application/pdf;base64,#{encoded}"
    end
  end
end
