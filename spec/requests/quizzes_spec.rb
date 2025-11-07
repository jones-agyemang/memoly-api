# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Quiz", type: :request do
  describe "POST /quiz" do
    before(:each) do
      post "/quiz", params: attributes
    end

    context "without topic" do
      let(:attributes) { { topic: [ nil, "" ].sample } }

      it "does not create quiz" do
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    VCR.use_cassette("open_ai_chat_completion") do
      context "has topic" do
        let(:attributes) { { topic: "Elixir and Erlang" } }

        xit "creates a quiz" do
          parsed_body = JSON.parse(response.body)

          expect(response).to have_http_status(:created)
          expect(parsed_body).to have_key("questions")
          expect(parsed_body["questions"]).to all(include("question", "choices", "answer", "explanation"))
        end
      end
    end
  end
end
