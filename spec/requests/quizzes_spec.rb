# frozen_string_literal: true

require "rails_helper"

RSpec.describe Quiz, type: :request do
  # Create a quiz from a given topic
  # Each quiz have multiple questions
  # Each question have multiple choices
  # Each question has one answer
  # Each user can have multiple response to the same quiz

  describe "POST /quizzes" do
    let(:attributes) do
      { topic: "Elixir and Erlang" }
    end

    before(:each) do
      post "/quizzes", params: attributes
    end

    context "without questions" do
      it "does not create quiz" do
        expect(response).to have_http_status(:created)
      end
    end

    context "with questions" do
      let(:attributes) do
        {
          topic: "Kotlin",
          questions_attributes: [
            {
              raw_content: "What is the sum of 10 and 15?",
              answer: "25",
              explanation: "10 add 15 produces 25",
              choices: [ "10", "25", "1015", "-5" ]
            }
          ]
        }
      end

      it "creates a quiz with questions" do
        expect do
          post "/quizzes", params: attributes
        end.to change(Question, :count)
      end
    end
  end
end
