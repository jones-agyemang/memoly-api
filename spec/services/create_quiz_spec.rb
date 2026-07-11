# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateQuiz, type: :service do
  context 'when there is no topic' do
    it 'does not create a quiz' do
      quiz_response = described_class.call('')

      expect(quiz_response).to eq([])
    end
  end

  context 'when there are topics' do
    let(:topics) do
      [
        'Gradient-descent is an optimisation method.',
        'CNNs have revolutionised image recognition technology'
      ]
    end

    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("OPENAI_ACCESS_TOKEN").and_return("FOO-KEY")

      client = instance_double(OpenAI::Client)
      allow(OpenAI::Client).to receive(:new).and_return(client)

      arguments = {
        title: "Gradient Descent Quiz",
        questions:[
          {
            question: "What is gradient descent primarily used for?",
            choices: [
              "Encrypting data",
              "Optimising a function by minimizing its value",
              "Sorting numbers",
              "Generating random variables"
            ],
            answer: "Optimising a function by minimizing its value",
            explanation: "Gradient descent is an optimisation method used to find values of parameters that reduce a function, often a loss or cost function."
          }
        ]
      }
      chat_response = {
        "choices": [
          {
            "message": {
              "tool_calls": [
                {
                  "function": {
                    "arguments": arguments.to_json
                  }
                }
              ],
            },
          }
        ]
      }
      allow(client).to receive(:chat).and_return(chat_response)
    end

    it 'returns quiz output constrained by the given schema' do
      quiz_response = described_class.call(topics)

      expect(quiz_response).to match_response_schema('quiz')
    end

    it 'keys results to the given topics' do
      quiz_response = described_class.call(topics)

      expect(quiz_response.keys).to contain_exactly(*topics)
    end
  end
end
