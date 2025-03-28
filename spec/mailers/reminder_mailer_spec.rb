require "rails_helper"

RSpec.describe ReminderMailer, type: :mailer do
  let!(:note) do
    create(:note, :with_reminder_due_today, raw_content: "Lorem ipsum")
  end

  let(:due_reminders) { Reminder.where(due_date: Time.zone.now.all_day).map(&:id) }

  it "delivers reminder email" do
    email = ReminderMailer.with(reminder_ids: due_reminders).due_notes_email

    expect { email.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it "renders the subject" do
    email = ReminderMailer.with(reminder_ids: due_reminders).due_notes_email
    expect(email.subject).to eq("Notes for Today")
  end

  it "includes due notes in email body" do
    email = ReminderMailer.with(reminder_ids: due_reminders).due_notes_email
    expect(email.body.encoded).to include("Lorem ipsum")
  end
end
