class ReminderMailer < ApplicationMailer
  default from: "notification@memoly.io"

  def due_notes_email
    @contents = params[:notes]

    mail(
      subject: "Notes for Today",
      to: "test@blackhole.postmarkapp.com",
      track_opens: true,
      message_stream: "outbound"
    )
  end
end
