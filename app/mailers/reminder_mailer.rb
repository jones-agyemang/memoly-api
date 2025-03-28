class ReminderMailer < ApplicationMailer
  def due_notes_email
    notes = Reminder.includes(:note)
                    .where(id: params[:reminder_ids])
                    .map(&:note)
                    .uniq

    @contents = notes.map(&:raw_content)

    mail(subject: "Notes for Today", to: "test@example.com")
  end
end
