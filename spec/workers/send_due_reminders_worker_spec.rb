# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe SendDueRemindersWorker, type: :worker do
  include ActiveJob::TestHelper

  before do
    clear_enqueued_jobs
  end

  it "enqueues a job" do
    expect do
      described_class.perform_async
    end.to change(SendDueRemindersWorker.jobs, :count).by(1)
  end

  context "when reminders are due" do
    it "enqueues an email" do
      note = create(:note)
      reminder = create(:reminder, note:, due_date: Date.today)

      expected_mailer_args = {
        user: note.user.id,
        notes: [ note.raw_content ],
        reminders: [ reminder.id ]
      }

      expect(ReminderMailer).to receive(:with).with(expected_mailer_args).and_call_original

      Sidekiq::Testing.inline! do
        SendDueRemindersWorker.perform_async
      end
    end
  end

  context "when there are no reminders due" do
    it "does not enqueue an email" do
      create(:note, :without_due_reminders)

      expect(ReminderMailer).not_to receive(:with).and_call_original

      Sidekiq::Testing.inline! do
        SendDueRemindersWorker.perform_async
      end
    end
  end
end
