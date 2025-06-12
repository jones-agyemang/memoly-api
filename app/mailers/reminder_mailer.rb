class ReminderMailer < ApplicationMailer
  after_deliver :mark_completed

  default from: "notification@memoly.io"

  def due_notes_email
    user = User.find params[:user]
    @contents = params[:notes]

    mail(
      subject: "Notes for Today",
      to: user&.email,
      track_opens: true,
      message_stream: "outbound"
    )
  end

  private

  def mark_completed
    Reminder.where(id: params[:reminders]).each { _1.update_attribute(:completed, true) }
  end
end
