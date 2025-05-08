# frozen_string_literal: true

class MissingAccessToken < StandardError
end

require "openai"

class CreateQuiz
  def self.call(topic)
    # Create client
    access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
    log_errors = true

    client = OpenAI::Client.new(access_token:, log_errors:)

    # set call definitions
    model = "gpt-4o"
    temperature = 0.7
    messages = [
      {
        role: "system",
        content: "Respond only with a valid JSON structure, without any Markdown or explanation text."
      },
      {
        role: "user",
        content: "Create multiple choice quiz with explanations based on: #{topic}"
      }
    ]
    tool_choice = "auto"
    tools = [
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

    response = client.chat(parameters: { model:, temperature:, messages:, tools:, tool_choice: })
    JSON.parse response.dig("choices", 0, "message", "tool_calls", 0, "function", "arguments")
  end
end
