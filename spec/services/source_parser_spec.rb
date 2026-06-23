# frozen_string_literal: true

require "rails_helper"

RSpec.describe SourceParser, type: :service do
  describe '.call' do
    let(:si) { create(:source_intake) }
    let(:client) { instance_double(OpenAI::Client) }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("OPENAI_ACCESS_TOKEN").and_return("FOO-KEY")

      allow(OpenAI::Client).to receive(:new).and_return(client)
    end

    describe 'operational exceptions' do
      context 'when source intake cannot be found' do
        it 'raises ActiveRecord::RecordNotFound' do
          source_intake_id = -1
          expect { described_class.call(source_intake_id:) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when LLM-client is invalid' do
        it 'raises connection error' do
          allow(client).to receive(:chat).and_raise(Faraday::BadRequestError)

          expect { described_class.call(source_intake_id: si.id) }.to raise_error(Faraday::BadRequestError)
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

        response = described_class.call(source_intake_id: si.id)

        expect(response).to match_response_schema('sourced_notes')
      end
    end
  end
end
