# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Quiz", type: :request do
  describe "POST /quiz" do
    subject(:post_quiz) { post "/quiz", params: attributes }

    context "without topic or user" do
      let(:attributes) { { topic: [ nil, "" ].sample } }

      it "does not create quiz" do
        post_quiz

        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context "when topic is provided" do
      let(:attributes) { { topic: "Elixir and Erlang" } }

      VCR.use_cassette("open_ai_chat_completion") do
        xit "creates a quiz" do
          post_quiz
          parsed_body = JSON.parse(response.body)

          expect(response).to have_http_status(:created)
          expect(parsed_body).to have_key("questions")
          expect(parsed_body["questions"]).to all(include("question", "choices", "answer", "explanation"))
        end
      end
    end

    context "when due notes should be used as the topic" do
      let(:user) { create(:user) }
      let(:attributes) { { user_id: user.id } }
      let(:math_note) { instance_double(Note, raw_content: "Linear algebra review") }
      let(:physics_note) { instance_double(Note, raw_content: "Study thermodynamics") }
      let(:due_notes_payload) do
        {
          "Mathematics" => [ math_note ],
          "Physics" => [ physics_note ]
        }
      end
      let(:quiz_payload) { { "questions" => [] } }

      before do
        allow(DueNotes).to receive(:call).and_return(due_notes_payload)
        allow(CreateQuiz).to receive(:call).and_return(quiz_payload)
      end

      it "builds the topic from due notes and creates a quiz" do
        post_quiz

        expect(DueNotes).to have_received(:call).with(user_id: user.id.to_s, date: Time.zone.today)
        expect(CreateQuiz).to have_received(:call).with("Mathematics: Linear algebra review\nPhysics: Study thermodynamics")
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to eq(quiz_payload)
      end
    end

    context "when due notes are unavailable" do
      let(:user) { create(:user) }
      let(:attributes) { { user_id: user.id } }

      before do
        allow(DueNotes).to receive(:call).and_return({})
      end

      it "responds with an error" do
        post_quiz

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
