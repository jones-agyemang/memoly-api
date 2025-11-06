# frozen_string_literal: true

require "rails_helper"

RSpec.describe DueNotes do
  include ActiveSupport::Testing::TimeHelpers

  let(:frozen_time) { Time.zone.local(2024, 6, 2, 9, 0, 0) }

  around do |example|
    travel_to(frozen_time) { example.run }
  end

  describe ".call" do
    subject(:service_call) { described_class.call(date:) }

    let(:date) { Time.zone.today }

    context "when notes have reminders due for the date" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let!(:note_due_today) do
        create(:note, :with_reminder_due_today, collection: create(:collection, user:), raw_content: "Due for primary user")
      end
      let!(:other_note_due_today) do
        create(:note, :with_reminder_due_today, collection: create(:collection, user: other_user), raw_content: "Due for secondary user")
      end
      let!(:completed_reminder) do
        create(:reminder, note: other_note_due_today, due_date: date.beginning_of_day + 4.hours, completed: true)
      end
      let!(:future_reminder) do
        create(:reminder, note: note_due_today, due_date: date + 1.day, completed: false)
      end

      it "returns a hash keyed by user id" do
        result = service_call

        expect(result).to be_a(Hash)
        expect(result.keys).to match_array([ user.id, other_user.id ])
      end

      it "includes notes that have incomplete reminders due on the date" do
        result = service_call
        due_reminder_id = note_due_today.reminders
                                       .where(completed: false, due_date: date.all_day)
                                       .pluck(:id)
                                       .first

        expect(result[user.id].map(&:id)).to eq([ note_due_today.id ])
        expect(result[user.id].first.reminder_id).to eq(due_reminder_id)
        expect(result[user.id].first.raw_content).to eq("Due for primary user")
      end

      it "excludes reminders that have already been completed" do
        reminder_ids = service_call[other_user.id].map(&:reminder_id)

        expect(reminder_ids).to all(be_present)
        expect(reminder_ids).not_to include(completed_reminder.id)
      end
    end

    context "when no reminders are due for the date" do
      let!(:note_with_reminder_for_other_day) do
        create(:note, :with_reminder_due_today, collection: create(:collection, user: create(:user)))
      end
      let(:date) { Time.zone.today - 1.day }

      it "returns an empty hash" do
        expect(service_call).to eq({})
      end
    end
  end
end
