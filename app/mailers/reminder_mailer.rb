class ReminderMailer < ApplicationMailer
  default from: "notification@memoly.io"

  def due_notes_email
    user = User.find params[:user_id]
    @contents = params[:notes]

    mail(
      subject: "Notes for Today",
      to: user&.email,
      track_opens: true,
      message_stream: "outbound"
    )
  end
end
