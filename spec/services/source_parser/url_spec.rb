# frozen_string_literal: true

require "rails_helper"

RSpec.describe SourceParser::Url, type: :service do
  describe '.call' do
    let(:source_intake) { create(:url_source) }
    let(:client) { instance_double(OpenAI::Client) }

    describe 'operational exceptions' do
      context 'when LLM-client is invalid' do
        it 'raises connection error' do
          allow(client).to receive(:chat).and_raise(Faraday::BadRequestError)

          expect { described_class.call(source_intake, client:) }.to raise_error(Faraday::BadRequestError)
        end
      end
    end

    context 'when source intake is found' do
      let(:arguments) do
        {
          collections: {
            "Sidekiq API": {
              parent_label: nil,
              position: 0,
              notes: [
                "# Intro to Sidekiq\\n Sidekiq is great for background processing"
              ]
            }
          }
        }
      end

      it 'returns output contrained by schema' do
        llm_response = {
          "choices" => [
            {
              "message" => {
                "tool_calls" => [
                  {
                    "function" => {
                      "arguments" => arguments.to_json
                    }
                  }
                ]
              }
            }
          ]
        }

        allow(client).to receive(:chat).and_return(llm_response)

        response = described_class.call(source_intake, client:)

        expect(response).to match_response_schema('sourced_notes')
      end
    end
  end
end
