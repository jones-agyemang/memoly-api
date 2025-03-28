# Preview all emails at http://localhost:3000/rails/mailers/reminder_mailer_mailer

class ReminderMailerPreview < ActionMailer::Preview
  def due_notes_email
    ReminderMailer.with(reminders: Reminder.all).due_notes_email
  end
end
