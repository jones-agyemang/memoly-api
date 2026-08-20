# frozen_string_literal: true

require "rails_helper"

RSpec.describe SourceParser::Core, type: :service do
  describe ".client" do
    let(:client) { instance_double(OpenAI::Client) }
    let(:responses_client) { instance_double(OpenAI::Responses) }
    let(:llm_response) do
      {
        "output" => [
          {
            "type" => "function_call",
            "name" => "source_notes",
            "arguments" => { collections: {} }.to_json
          }
        ]
      }
    end
    let(:source_intake) { instance_double(SourceIntake, source: "content") }

    around do |example|
      original_client = described_class.instance_variable_get(:@client)
      client_was_defined = described_class.instance_variable_defined?(:@client)
      described_class.remove_instance_variable(:@client) if client_was_defined

      example.run
    ensure
      described_class.remove_instance_variable(:@client) if described_class.instance_variable_defined?(:@client)
      described_class.instance_variable_set(:@client, original_client) if client_was_defined
    end

    it "reuses one OpenAI client" do
      allow(ENV).to receive(:fetch).with("OPENAI_ACCESS_TOKEN").and_return("FOO-KEY")
      expect(OpenAI::Client).to receive(:new).
        once.
        with(access_token: "FOO-KEY", log_errors: true).
        and_return(client)

      expect(described_class.client).to equal(client)
      expect(described_class.client).to equal(client)
    end

    it "shares the client across parser subclasses" do
      allow(ENV).to receive(:fetch).with("OPENAI_ACCESS_TOKEN").and_return("FOO-KEY")
      allow(client).to receive(:responses).and_return(responses_client)
      allow(responses_client).to receive(:create).and_return(llm_response)
      allow(Net::HTTP).to receive(:get).and_return("content")
      expect(OpenAI::Client).to receive(:new).once.and_return(client)

      SourceParser::RawText.call(source_intake)
      SourceParser::Url.call(source_intake)

      expect(responses_client).to have_received(:create).twice
    end
  end
end
