require 'rails_helper'

RSpec.describe "Notes", type: :request do
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

    context "invalid attributes" do
      it "does not create a note" do
        post "/notes", params: {}

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
