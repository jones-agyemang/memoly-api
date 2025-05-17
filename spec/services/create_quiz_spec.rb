# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateQuiz do
  context "missing access token" do
    xit "raises an error" do
      allow(ENV).to receive(:fetch) { nil }

      error_msg = "key not found: \"OPENAPI_ACCESS_TOKEN\""
      expect { described_class.call "" }.to raise_error(KeyError, error_msg)
    end
  end

  context "when access token is provided" do
    it "creates quiz" do
      topic = "Advanced Ruby"

      VCR.use_cassette("open_ai_chat_completion") do
        response = described_class.call topic

        expect(response).to have_key("title")
        expect(response).to have_key("questions")
        expect(response["questions"]).to all(include("question", "choices", "answer", "explanation"))
      end
    end
  end
end
