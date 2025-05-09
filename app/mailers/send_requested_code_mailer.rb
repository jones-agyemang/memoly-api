class SendRequestedCodeMailer < ApplicationMailer
  def send_authentication_code
    @user = User.find(params[:user_id])

    mail(to: @user.email, subject: "Authentication Code")
  end
end
