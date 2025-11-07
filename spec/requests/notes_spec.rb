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

      context "when collection is undefined" do
        it "creates and assigns a new note in the default collection" do
          travel_to(Time.parse("2025-03-28 15:30:00")) do
            post "/users/#{user.id}/notes", params: valid_attributes, headers: { "ACCEPT": "application/json" }

            response_body = JSON.parse(response.body)

            expect(response).to have_http_status(:created)

            expect(response_body).to include(
              "id" => be_a(Integer),
              "user" => { "email" => user.email },
              "collection" => { "label" => Collection::DEFAULT_CATEGORY_LABEL },
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

      context "when collection is defined" do
        let(:collection) { create(:collection, user:) }
        let(:valid_attributes) do
          {
            note: {
              raw_content: "Lorem ipsum",
              collection_id: collection.id
            }
          }
        end

        it "creates and assigns a new note in the specified collection" do
          travel_to(Time.parse("2025-03-28 15:30:00")) do
            post "/users/#{user.id}/notes", params: valid_attributes, headers: { "ACCEPT": "application/json" }

            response_body = JSON.parse(response.body)

            expect(response).to have_http_status(:created)

            expect(response_body).to include(
              "id" => be_a(Integer),
              "user" => { "email" => user.email },
              "collection" => { "label" => collection.label },
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
      create(:note, collection: create(:collection, user:))
      create(:note, collection: create(:collection, user: other_user))

      get user_notes_url(user_id: user.id), params: {}, headers: { "ACCEPT" => "application/json" }

      response_body = JSON.parse(response.body)

      expect(response_body.map { _1["user"]["email"] }).to include user.email
      expect(response_body.map { _1["user"]["email"] }).not_to include other_user.email
    end

    describe "filter by collection" do
      let(:maths) { create(:collection, user:, label: "Maths") }
      let(:physics) { create(:collection, user:, label: "Physics") }

      before do
        create(:note, raw_content: "Linear algebra", collection: maths)
        create(:note, raw_content: "Quantum physics", collection: physics)
      end

      context "when collection is undefined" do
        it "returns notes unscoped by collection" do
          get "/users/#{user.id}/notes", params: { dummy: "foo" }, headers: { "ACCEPT" => "application/json" }

          response_body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(response_body).to be_an(Array)
          expect(response_body.size).to eq(2)
          expect(response_body.first).to include(
            "id" => be_a(Integer),
            "raw_content" => "Quantum physics"
            )
          expect(response_body.second).to include(
            "id" => be_a(Integer),
            "raw_content" => "Linear algebra"
          )
        end
      end

      context "when collection is defined" do
        it "returns notes scoped by collection" do
          get "/users/#{user.id}/notes", params: { note: { collection_id: maths.id } }, headers: { "ACCEPT" => "application/json" }

          response_body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(response_body).to be_an(Array)
          expect(response_body.size).to eq(1)
          expect(response_body.first).to include(
            "id" => be_a(Integer),
            "raw_content" => "Linear algebra"
          )
        end
      end
    end

    it 'returns notes ordered by date modified' do
      create(:user)
      create(:note, raw_content: "First note", collection: create(:collection, user:))
      create(:note, raw_content: "Second note", collection: create(:collection, user:))

      get "/users/#{user.id}/notes", headers: { "ACCEPT" => "application/json" }

      response_body = JSON.parse(response.body)
      expected_response_body = response_body.map { _1["raw_content"] }

      expect(response).to have_http_status(:ok)
      expect(expected_response_body).to eq [ 'Second note', 'First note' ]
    end
  end

  describe "PATCH /users/:user_id/notes/:id" do
    let(:user) { create(:user) }
    let!(:note) { create(:note, collection: create(:collection, user:), raw_content: "Original note") }

    it "updates the note for the user" do
      travel_to(Time.zone.parse("2025-05-29 10:30:00")) do
        patch "/users/#{user.id}/notes/#{note.id}",
              params: { note: { raw_content: "Updated note" } },
              headers: { "ACCEPT" => "application/json" }

        response_body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(note.reload.raw_content).to eq "Updated note"
        expect(response_body).to include(
          "id" => note.id,
          "raw_content" => "Updated note",
          "updated_at" => note.updated_at.as_json
        )
      end
    end

    it "returns bad request when params are missing" do
      patch "/users/#{user.id}/notes/#{note.id}", headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:bad_request)
    end

    it "returns not found when the note belongs to another user" do
      other_user = create(:user)
      other_note = create(:note, collection: create(:collection, user: other_user))

      patch "/users/#{user.id}/notes/#{other_note.id}",
            params: { note: { raw_content: "Updated note" } },
            headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /users/:user_id/notes/:id" do
    let(:user) { create(:user) }
    let!(:note) { create(:note, collection: create(:collection, user:)) }

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
      other_note = create(:note, collection: create(:collection, user: other_user))

      delete "/users/#{user.id}/notes/#{other_note.id}", headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:not_found)
    end
  end
end
