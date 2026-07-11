# frozen_string_literal: true

class MissingAccessToken < StandardError
end

require "openai"

class CreateQuiz
  def self.call(topics)
    return [] unless topics.present?

    # Create client
    access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
    log_errors = true

    client = OpenAI::Client.new(access_token:, log_errors:)

    # set call definitions
    model = "gpt-5.4"
    temperature = 0.7
    tool_choice = "auto"

    parsed_responses = {}
    topics.each do |topic|
      messages = self.form_message_for(topic:)
      response = client.chat(parameters: { model:, temperature:, messages:, tools: self.tools_definition, tool_choice: })
      response = ActiveSupport::HashWithIndifferentAccess.new(response)
      result = JSON.parse response.dig("choices", 0, "message", "tool_calls", 0, "function", "arguments")
      parsed_responses[topic] = result
    end

    parsed_responses
  end

  def self.form_message_for(topic:)
    [
      {
        role: "system",
        content: "Respond only with a valid JSON structure, without any Markdown or explanation text."
      },
      {
        role: "user",
        content: "Create multiple choice quiz with explanations based on: #{topic}"
      }
    ]
  end

  def self.tools_definition
    [
      {
        type: "function",
        function: {
          name: "create_quiz",
          parameters: {
            type: "object",
            properties: {
              title: { type: "string" },
              questions: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    question: { type: "string" },
                    choices: { type: "array", items: { type: "string" } },
                    answer: { type: "string" },
                    explanation: { type: "string" }
                  },
                  required: [ "question", "choices", "answer", "explanation" ]
                }
              }
            },
            required: [ "questions", "title" ]
          }
        }
      }
    ]
  end
end
