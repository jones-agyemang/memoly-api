require "rails_helper"

RSpec.describe SendRequestedCodeMailer, type: :mailer do
  describe "send_authentication_code" do
    let(:user) { create(:user, :with_auth_code, email: 'test@example.com') }
    let(:mail) do
      described_class.with(user_id: user.id).send_authentication_code
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Send authentication code")
      expect(mail.to).to eq([ user.email ])
      expect(mail.from).to eq([ "from@example.com" ])
    end

    it "renders authentication code within message body" do
      auth_code = user.authentication_code.code
      expected_mail_body = "Your Authentication Code is: #{auth_code}"

      expect(mail.body.encoded).to match expected_mail_body
    end

    it "renders expiry date within message body" do
      expiry_time = user.authentication_code.expires_at
      expected_mail_body = "Your code is valid for the next 15 minutes. It will no longer valid after #{expiry_time}"

      expect(mail.body.encoded).to match expected_mail_body
    end
  end
end
