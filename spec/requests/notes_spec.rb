require 'rails_helper'

RSpec.describe "Notes", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  describe "POST /notes" do
    context "valid attributes" do
      let(:valid_attributes) do
        {
          note: {
            raw_content: "Lorem ipsum"
          }
        }
      end

      it "creates a new note" do
        travel_to(Time.parse("2025-03-28 15:30:00")) do
          post "/notes", params: valid_attributes, headers: { "ACCEPT": "application/json" }

          response_body = JSON.parse(response.body)

          expect(response).to have_http_status(:created)

          expect(response_body).to include(
            "id" => be_a(Integer),
            "raw_content" => "Lorem ipsum",
            "reminders" => [
              { "due_date" => "2025-03-29", "completed" => false },
              { "due_date" => "2025-03-31", "completed" => false },
              { "due_date" => "2025-04-04", "completed" => false },
              { "due_date" => "2025-04-11", "completed" => false },
              { "due_date" => "2025-04-17", "completed" => false }
            ]
          )
        end
      end
    end

    context "invalid attributes" do
      it "does not create a note" do
        post "/notes", params: {}

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "GET /notes" do
    it "returns a list of notes" do
      # Arrange: create some notes
      Note.create!(raw_content: "First note")
      Note.create!(raw_content: "Second note")

      # Act: perform the GET request
      get "/notes", headers: { "ACCEPT" => "application/json" }

      # Assert: check the response
      expect(response).to have_http_status(:ok)

      response_body = JSON.parse(response.body)

      expect(response_body).to be_an(Array)
      expect(response_body.size).to eq(2)

      expect(response_body.first).to include(
        "id" => be_a(Integer),
        "raw_content" => "First note"
      )
    end
  end
end
