# frozen_string_literal: true

require "base64"

module SourceParser
  class Pdf < Core
    def parse
      response = client.responses.create(parameters: {
        model: "gpt-5.4",
        input: [
          {
            role: "system",
            content: [ { type: "input_text", text: SYSTEM_MESSAGE.fetch(:content) } ]
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
        ],
        tools: responses_tools_definition,
        tool_choice: "required"
      })

      tool_call = response.fetch("output").find do |item|
        item["type"] == "function_call" && item["name"] == "create_notes"
      end
      raise JSON::ParserError, "The model did not return a create_notes tool call" unless tool_call

      JSON.parse(tool_call.fetch("arguments"))
    end

    private

    def source_instructions
      "Use the attached PDF (#{source_intake.source}) to generate notes categorised by collection. "
    end

    def encoded_document
      encoded = Base64.strict_encode64(source_intake.document.download)
      "data:application/pdf;base64,#{encoded}"
    end

    def responses_tools_definition
      tools_definition.map do |tool|
        { type: "function", **tool.fetch(:function) }
      end
    end
  end
end
