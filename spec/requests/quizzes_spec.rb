# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Quiz", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in_with_encrypted_cookie(user)
  end

  describe "POST /quiz" do
    subject(:post_quiz) { post "/quiz", params: attributes }

    let(:quiz_payload) do
      {
        "Elixir and Erlang" => {
          "title" => "Elixir and Erlang",
          "questions" => [
            {
              "question" => "What runs on the BEAM?",
              "choices" => [ "Elixir", "Ruby" ],
              "answer" => "Elixir",
              "explanation" => "Elixir runs on the BEAM virtual machine."
            }
          ]
        }
      }
    end

    context "when a top-level topic is provided" do
      let(:attributes) { { topic: "Elixir and Erlang" } }

      it "creates a quiz from the topic" do
        expect(CreateQuiz).to receive(:call)
          .with([ "Elixir and Erlang" ])
          .and_return(quiz_payload)

        post_quiz

        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to eq(quiz_payload)
      end
    end

    context "when a wrapped topic array is provided" do
      let(:attributes) { { quiz: { topic: [ "Elixir and Erlang" ] } } }

      it "creates a quiz from the wrapped topic" do
        expect(CreateQuiz).to receive(:call)
          .with([ "Elixir and Erlang" ])
          .and_return(quiz_payload)

        post_quiz

        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to eq(quiz_payload)
      end
    end

    context "when the topic is blank" do
      let(:attributes) { { topic: "" } }

      it "does not create a quiz" do
        expect(CreateQuiz).not_to receive(:call)

        post_quiz

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to eq("message" => "Topic is missing")
      end
    end

    context "when due notes are available" do
      let(:attributes) { { user_id: user.id, date: "2026-05-26" } }

      let(:math_note) { instance_double(Note, raw_content: "Linear algebra review") }
      let(:physics_note) { instance_double(Note, raw_content: "Study thermodynamics") }

      before do
        allow(DueNotes).to receive(:call)
          .with(user_id: user.id, date: Date.new(2026, 5, 26))
          .and_return(
            "Mathematics" => [ math_note ],
            "Physics" => [ physics_note ]
          )
      end

      it "creates a quiz from due notes" do
        expect(CreateQuiz).to receive(:call)
          .with([
            "Mathematics: Linear algebra review",
            "Physics: Study thermodynamics"
          ])
          .and_return(quiz_payload)

        post_quiz

        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to eq(quiz_payload)
      end

      context "when a collection contains multiple due notes" do
        let(:second_math_note) { instance_double(Note, raw_content: "Practice matrix multiplication") }

        before do
          allow(DueNotes).to receive(:call)
            .with(user_id: user.id, date: Date.new(2026, 5, 26))
            .and_return("Mathematics" => [ math_note, second_math_note ])
        end

        it "creates a separate quiz topic for each source note" do
          expect(CreateQuiz).to receive(:call)
            .with([
              "Mathematics: Linear algebra review",
              "Mathematics: Practice matrix multiplication"
            ])
            .and_return(quiz_payload)

          post_quiz

          expect(response).to have_http_status(:created)
        end
      end
    end

    context "when due notes are requested with an invalid date" do
      let(:attributes) { { user_id: user.id, date: "not-a-date" } }
      let(:note) { instance_double(Note, raw_content: "Backpropagation review") }

      before do
        allow(DueNotes).to receive(:call)
          .with(user_id: user.id, date: Time.zone.today)
          .and_return("Neural Networks" => [ note ])
      end

      it "falls back to today's date" do
        expect(CreateQuiz).to receive(:call)
          .with([ "Neural Networks: Backpropagation review" ])
          .and_return(quiz_payload)

        post_quiz

        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to eq(quiz_payload)
      end
    end

    context "when due notes are unavailable" do
      let(:attributes) { { user_id: user.id } }

      before do
        allow(DueNotes).to receive(:call).and_return({})
      end

      it "responds with a validation error" do
        expect(CreateQuiz).not_to receive(:call)

        post_quiz

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to eq("message" => "Topic is missing")
      end
    end
  end
end
