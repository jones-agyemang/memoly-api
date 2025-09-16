require 'rails_helper'

RSpec.describe "Notes", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  describe "POST /users/:user_id/notes" do
    let(:user) { create(:user) }

    context "valid attributes" do
      let(:valid_attributes) do
        {
          note: {
            raw_content: "Lorem ipsum"
          }
        }
      end

      it "creates a new note for user" do
        travel_to(Time.parse("2025-03-28 15:30:00")) do
          post "/users/#{user.id}/notes", params: valid_attributes, headers: { "ACCEPT": "application/json" }

          response_body = JSON.parse(response.body)

          expect(response).to have_http_status(:created)

          expect(response_body).to include(
            "id" => be_a(Integer),
            "user" => {
              "email" => user.email
            },
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
        post "/users/#{user.id}/notes", params: {}

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "GET /users/:user_id/notes" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it "returns user notes" do
      create(:note, user:)
      create(:note, user: other_user)


      get "/users/#{user.id}/notes", headers: { "ACCEPT" => "application/json" }

      response_body = JSON.parse(response.body)

      expect(response_body.map { _1["user"]["email"] }).to include user.email
      expect(response_body.map { _1["user"]["email"] }).not_to include other_user.email
    end

    it "returns list of notes" do
      create(:note, raw_content: "First note", user:)
      create(:note, raw_content: "Second note", user:)

      get "/users/#{user.id}/notes", headers: { "ACCEPT" => "application/json" }

      response_body = JSON.parse(response.body)

      expect(response_body).to be_an(Array)
      expect(response_body.size).to eq(2)
      expect(response).to have_http_status(:ok)
      expect(response_body.first).to include(
        "id" => be_a(Integer),
        "raw_content" => "Second note"
      )
    end

    it 'returns notes ordered by date modified' do
      create(:user)
      create(:note, raw_content: "First note", user:)
      create(:note, raw_content: "Second note", user:)

      get "/users/#{user.id}/notes", headers: { "ACCEPT" => "application/json" }

      response_body = JSON.parse(response.body)
      expected_response_body = response_body.map { _1["raw_content"] }

      expect(response).to have_http_status(:ok)
      expect(expected_response_body).to eq [ 'Second note', 'First note' ]
    end
  end

  describe "DELETE /users/:user_id/notes/:id" do
    let(:user) { create(:user) }
    let!(:note) { create(:note, user:) }

    it "removes the note for the user" do
      delete "/users/#{user.id}/notes/#{note.id}", headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:no_content)
      expect(Note.exists?(note.id)).to be(false)
    end

    it "removes associated reminders" do
      reminder = create(:reminder, note:)

      delete "/users/#{user.id}/notes/#{note.id}", headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:no_content)
      expect(Reminder.exists?(reminder.id)).to be(false)
    end

    it "returns not found when the note belongs to another user" do
      other_user = create(:user)
      other_note = create(:note, user: other_user)

      delete "/users/#{user.id}/notes/#{other_note.id}", headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:not_found)
    end
  end
end
