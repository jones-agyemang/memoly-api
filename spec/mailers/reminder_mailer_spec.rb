require "rails_helper"

RSpec.describe ReminderMailer, type: :mailer do
  let(:raw_content) { "Lorem ipsum" }
  let(:user) { create(:user) }
  let(:notes) { create_list(:note, 3, raw_content:, user:).map(&:raw_content) }

  subject(:email) { described_class.with(user_id: user.id, notes:).due_notes_email }

  it "delivers reminder email" do
    expect { email.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it "renders the subject" do
    expect(email.subject).to eq("Notes for Today")
  end

  it "includes due notes in email body" do
    expect(email.body.encoded).to include(raw_content)
  end
end
