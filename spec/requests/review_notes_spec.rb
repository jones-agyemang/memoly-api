# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "ReviewNotes", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  let!(:user) { create(:user) }

  describe "due_notes" do
    let(:collection) { create(:collection, user:) }
    let(:other_collection) { create(:collection, user:) }
    let!(:note) { create(:note, collection:) }
    let!(:other_note) { create(:note, collection: other_collection) }

    context "when there are notes" do
      it "returns due notes" do
        travel_to(1.day.from_now) do
          get user_due_notes_path(user_id: user.id), params: {}, headers: {}

          response_body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(response_body).to contain_exactly(
            a_hash_including(
              collection.label => {
                "id" => note.id,
                "raw_content" => note.raw_content,
                "source" => note.source
              }
            ),
            a_hash_including(
              other_collection.label => {
                "id" => other_note.id,
                "raw_content" => other_note.raw_content,
                "source" => other_note.source
              }
            )
          )
        end
      end
    end
  end
end
