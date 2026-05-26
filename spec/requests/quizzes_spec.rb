# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Quiz", type: :request do
  describe "POST /quiz" do
    subject(:post_quiz) { post "/quiz", params: attributes }

    context "without topic" do
      let(:attributes) { { topic: [ nil, "" ].sample } }

      it "does not create quiz" do
        expect(CreateQuiz).not_to receive(:call)

        post_quiz

        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context "when topic is provided" do
      let(:attributes) { { topic: "Elixir and Erlang" } }

      VCR.use_cassette("open_ai_chat_completion") do
        it "creates a quiz" do
          allow(CreateQuiz).to receive('call') { {"questions": {}}}

          post_quiz
          parsed_body = JSON.parse(response.body)

          expect(response).to have_http_status(:created)
          expect(parsed_body).to have_key("questions")
          expect(parsed_body["questions"]).to all(include("question", "choices", "answer", "explanation"))
        end
      end
    end
  end
end
