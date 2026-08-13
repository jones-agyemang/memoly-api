# Preview all emails at http://localhost:3000/rails/mailers/send_requested_code_mailer_mailer
class SendRequestedCodeMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/send_requested_code_mailer_mailer/send_authentication_code
  def send_authentication_code
    user = FactoryBot.create(:user)
    FactoryBot.create(:authentication_code, user:)

    SendRequestedCodeMailer.with(user_id: user.id).send_authentication_code
  end
end
