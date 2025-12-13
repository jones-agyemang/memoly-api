# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "ReviewNotes", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  let!(:user) { create(:user) }

  describe "due_notes" do
    let(:collection) { create(:collection, user:) }
    let(:other_collection) { create(:collection, user:) }
    let(:target_date) { Date.new(2024, 6, 2) }
    let(:other_date) { target_date + 1.day }
    let!(:note_due_on_target_date) do
      create(:note, :without_due_reminders, collection:).tap do |note|
        create(:reminder, note:, due_date: target_date.beginning_of_day + 9.hours, completed: false)
      end
    end
    let!(:second_note_due_on_target_date) do
      create(:note, :without_due_reminders, collection: other_collection).tap do |note|
        create(:reminder, note:, due_date: target_date.beginning_of_day + 10.hours, completed: false)
      end
    end
    let!(:note_due_on_other_date) do
      create(:note, :without_due_reminders, collection:).tap do |note|
        create(:reminder, note:, due_date: other_date.beginning_of_day + 11.hours, completed: false)
      end
    end

    def expected_payload_for(collection_label, note)
      a_hash_including(
        collection_label => {
          "id" => note.id,
          "raw_content" => note.raw_content,
          "source" => note.source
        }
      )
    end

    context "when a specific date is supplied" do
      it "returns only the notes due on that date" do
        get user_due_notes_path(user_id: user.id), params: { date: target_date.to_s }, headers: {}

        response_body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(response_body).to contain_exactly(
          expected_payload_for(collection.label, note_due_on_target_date),
          expected_payload_for(other_collection.label, second_note_due_on_target_date)
        )
      end
    end

    context "when no date is supplied" do
      it "defaults to the current date" do
        travel_to(target_date.beginning_of_day + 8.hours) do
          get user_due_notes_path(user_id: user.id), params: {}, headers: {}

          response_body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(response_body).to contain_exactly(
            expected_payload_for(collection.label, note_due_on_target_date),
            expected_payload_for(other_collection.label, second_note_due_on_target_date)
          )
        end
      end
    end
  end
end
