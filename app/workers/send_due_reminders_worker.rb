class SendDueRemindersWorker
  include Sidekiq::Job

  queue_as :default

  def perform(*args)
    reminder_ids = Reminder.where(due_date: Time.zone.now.all_day).map(&:id)

    return unless reminder_ids.any?

    ReminderMailer.with(reminder_ids:).due_notes_email.deliver_later
  end
end
