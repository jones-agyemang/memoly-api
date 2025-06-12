require "rails_helper"

RSpec.describe ReminderMailer, type: :mailer do
  let(:raw_content) { "Lorem ipsum" }
  let(:user) { create(:user) }
  let!(:notes) do
    create_list(:note, 3, :with_reminder_due_today, raw_content:, user:)
  end

  subject(:email) { described_class.with(user: user.id, notes:).due_notes_email }

  it "delivers reminder email" do
    expect { email.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it "renders the subject" do
    expect(email.subject).to eq("Notes for Today")
  end

  it "includes due notes in email body" do
    expect(email.body.encoded).to include(raw_content)
  end

  context "successful delivery" do
    it "updates reminder status" do
      reminders = Reminder.select { |reminder| reminder.due_date.to_date.eql?(Date.today.to_date) }.pluck(:id)

      expect do
        described_class.with(user: user.id, notes: [], reminders:)
                       .due_notes_email
                       .deliver_now
      end.to change { Reminder.where(completed: true).count }.by(3)
    end
  end

  context "unsuccessful delivery" do
    it "does not update reminder status" do
      reminders = Reminder.select { |reminder| reminder.due_date.to_date.eql?(Date.today.to_date) }.pluck(:id)

      allow_any_instance_of(ReminderMailer).to receive(:due_notes_email).and_raise(Net::SMTPFatalError.new("Simulated delivery failure"))

      expect do
        begin
          described_class.with(user: user.id, notes: [], reminders:)
                         .due_notes_email
                         .deliver_now
        rescue Net::SMTPFatalError
          # no-op
        end
      end.not_to change { Reminder.where(completed: true).count }
    end
  end
end
