# frozen_string_literal: true

require "rails_helper"

RSpec.describe SourceParser::Url, type: :service do
  describe '.call' do
    let(:source_intake) { create(:url_source) }
    let(:client) { instance_double(OpenAI::Client) }
    let(:llm_response) do
      {
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
    end

    subject(:parse_source!) { described_class.call(source_intake, client:) }

    describe 'operational exceptions' do
      context "when source url is unreachable" do
        let(:source_intake) { create(:url_source, source: Faker::Internet.url) }

        it "raises a socket error" do
          expect do
            parse_source!
          end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Source type is unreachable")
        end
      end

      context 'when LLM-client is invalid' do
        it 'raises connection error' do
          allow(client).to receive(:chat).and_raise(Faraday::BadRequestError)

          expect { described_class.call(source_intake, client:) }.to raise_error(Faraday::BadRequestError)
        end
      end
    end

    context 'when source intake is found' do
      context "when source from url is parseable" do
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
          allow(client).to receive(:chat).and_return(llm_response)

          response = described_class.call(source_intake, client:)

          expect(response).to match_response_schema('sourced_notes')
        end

        context 'when LLM-client cannot parse the given URL' do
          let(:arguments) do
            {
              "code": "source_unavailable",
              "message": "Source URL cannot be accessed"
            }
          end

          it 'returns output constrained by error schema' do
            allow(client).to receive(:chat).and_return(llm_response)
            response = parse_source!

            expect(response).to match_response_schema('report_source_error')
          end
        end
      end
    end
  end
end
