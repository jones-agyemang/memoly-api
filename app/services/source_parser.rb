# frozen_string_literal: true

class SourceParser
  attr_reader :source_intake

  def initialize(source_intake_id)
    @source_intake = SourceIntake.find(source_intake_id)
  end

  def self.call(source_intake_id:)
    new(source_intake_id).parse
  end

  def parse
    access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
    client = OpenAI::Client.new(access_token:, log_errors: true)

    system_message = {
      role: "system",
      content: "You are a judicious, safety-conscious, professional-grade Educative content creator"
    }
    user_message = {
      role: "user",
      content: "Use the contents of the following URL(#{@source_intake.source}) to generate notes categorised by collection. Group similar collection theme(s) tightly to avoid having too many loosely connected collections. Use sub-categories for a natural hierarchical ordering of ideas. Return collections as an object keyed by collection label. For each collection, include parent_label as null for top-level collections or the parent collection label for sub-categories, position as a zero-based sibling order, and notes as an array of note strings. Use markdown formatting for notes. Provide title as a header for each note. Wrap code blocks in triple backticks with language tag and inline code with single backticks"
    }

    response = client.chat(parameters: {
      model: "gpt-5.4",
      temperature: 0.7,
      messages: [ system_message, user_message ],
      tools: tools_definition,
      tool_choice: "required"
    })
    arguments = response.dig("choices", 0, "message", "tool_calls", 0, "function", "arguments")
    JSON.parse(arguments)
  end

  def tools_definition
    [
      {
        type: "function",
        function: {
          name: "create_notes",
          parameters: {
            type: "object",
            properties: {
              collections: {
                type: "object",
                minProperties: 1,
                additionalProperties: {
                  type: "object",
                  properties: {
                    parent_label: { type: [ "string", "null" ] },
                    position: { type: "integer", minimum: 0 },
                    notes: {
                      type: "array",
                      minItems: 1,
                      items: { type: "string" }
                    }
                  },
                  required: [ "parent_label", "position", "notes" ]
                }
              }
            },
            required: [ "collections" ]
          }
        }
      }
    ]
  end
end
