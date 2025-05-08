# frozen_string_literal: true

require "rails_helper"

RSpec.describe Quiz, type: :request do
  describe "POST /quiz" do
    before(:each) do
      post "/quiz", params: attributes
    end

    context "without topic" do
      let(:attributes) { { topic: "" } }

      it "does not create quiz" do
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context "has topic" do
      let(:attributes) { { topic: "Elixir and Erlang" } }

      it "creates a quiz" do
        expected_response_body =  {
          data: {
            title: "Advanced Elixir",
            questions: [
              {
                raw_content: "What is the sum of 10 and 15?",
                answer: "25",
                explanation: "10 add 15 produces 25",
                choices: [ "10", "25", "1015", "-5" ]
              }
            ]
          }
        }

        expect(response.body).to eq(expected_response_body)
      end
    end
  end
end
