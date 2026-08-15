# frozen_string_literal: true

require "rails_helper"

RSpec.describe DueNotes do
  include ActiveSupport::Testing::TimeHelpers

  let(:frozen_time) { Time.zone.local(2024, 6, 2, 9, 0, 0) }

  around do |example|
    travel_to(frozen_time) { example.run }
  end

  describe ".call" do
    let(:include_completed) { false }
    subject(:fetch_due_notes) { described_class.call(date:, include_completed:) }

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
        due_notes = fetch_due_notes

        expect(due_notes).to be_a(Hash)
        expect(due_notes.keys).to match_array([ user.id, other_user.id ])
      end

      it "includes notes that have incomplete reminders due on the date" do
        due_notes = fetch_due_notes
        due_reminder_id = note_due_today.reminders
                                       .where(completed: false, due_date: date.all_day)
                                       .pluck(:id)
                                       .first

        expect(due_notes[user.id].map(&:id)).to eq([ note_due_today.id ])
        expect(due_notes[user.id].first.reminder_id).to eq(due_reminder_id)
        expect(due_notes[user.id].first.raw_content).to eq("Due for primary user")
      end

      context "with `completed` flag toggled on" do
        let(:include_completed) { true }

        it "includes notes that have completed reminders due on the date" do
          due_notes = fetch_due_notes.values.flatten

          expect(due_notes).to include(note_due_today)
          expect(due_notes).to include(other_note_due_today)
        end
      end

      it "excludes reminders that have already been completed" do
        reminder_ids = fetch_due_notes[other_user.id].map(&:reminder_id)

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
        expect(fetch_due_notes).to eq({})
      end
    end
  end

  describe ".call with user_id" do
    subject(:fetch_due_notes) { described_class.call(date:, user_id: user.id) }

    let(:user) { create(:user) }
    let(:collection) { create(:collection, user:, label: "Gradient Descent") }
    let(:other_collection) { create(:collection, user:, label: "Convolutional Neural Networks") }
    let(:date) { Date.new(2024, 6, 2) }
    let!(:note_due_today) do
      create(:note, :without_due_reminders, collection:).tap do |note|
        create(:reminder, note:, due_date: date.beginning_of_day + 8.hours, completed: false)
      end
    end
    let!(:other_collection_note_due_today) do
      create(:note, :without_due_reminders, collection: other_collection).tap do |note|
        create(:reminder, note:, due_date: date.beginning_of_day + 9.hours, completed: false)
      end
    end
    let!(:note_due_on_other_day) do
      create(:note, :without_due_reminders, collection:).tap do |note|
        create(:reminder, note:, due_date: (date + 1.day).beginning_of_day + 10.hours, completed: false)
      end
    end

    it "returns notes grouped by collection label for the given date" do
      due_notes = fetch_due_notes

      expect(due_notes.keys).to contain_exactly(collection.label, other_collection.label)
      expect(due_notes[collection.label].map(&:id)).to eq([ note_due_today.id ])
      expect(due_notes[other_collection.label].map(&:id)).to eq([ other_collection_note_due_today.id ])
      expect(due_notes[collection.label].first.collection_label).to eq(collection.label)
    end
  end
end
