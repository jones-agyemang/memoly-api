class ReminderMailer < ApplicationMailer
  default from: "notification@memoly.io"

  def due_notes_email
    notes = Reminder.includes(:note)
                    .where(id: params[:reminder_ids])
                    .map(&:note)
                    .uniq

    @contents = notes.map(&:raw_content)

    mail(
      subject: "Notes for Today",
      to: "test@blackhole.postmarkapp.com",
      track_opens: true,
      message_stream: "outbound"
    )
  end
end
