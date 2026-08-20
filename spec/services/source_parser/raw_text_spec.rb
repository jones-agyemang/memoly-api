# frozen_string_literal: true

require "rails_helper"

RSpec.describe SourceParser::RawText, type: :service do
  describe '.call' do
    let(:source_intake) { create(:raw_text) }
    let(:client) { instance_double(OpenAI::Client) }
    let(:responses_client) { instance_double(OpenAI::Responses) }

    before do
      allow(client).to receive(:responses).and_return(responses_client)
    end

    describe 'operational exceptions' do
      context 'when LLM-client is invalid' do
        it 'raises connection error' do
          allow(responses_client).to receive(:create).and_raise(Faraday::BadRequestError)

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
          "output" => [
            {
              "type" => "function_call",
              "name" => "source_notes",
              "arguments" => arguments.to_json
            }
          ]
        }

        allow(responses_client).to receive(:create).and_return(llm_response)

        response = described_class.call(source_intake, client:)

        expect(response).to match_response_schema('sourced_notes')
      end

      it "enables high-context web search for deep research" do
        allow(responses_client).to receive(:create).and_return({
          "output" => [
            {
              "type" => "function_call",
              "name" => "source_notes",
              "arguments" => arguments.to_json
            }
          ]
        })

        described_class.call(source_intake, client:)

        expect(responses_client).to have_received(:create) do |parameters:|
          expect(parameters.fetch(:tools)).to include(
            type: "web_search",
            search_context_size: "high"
          )
          expect(parameters.fetch(:tools)).to include(
            hash_including(type: "function", name: "source_notes")
          )
        end
      end
    end
  end
end
