class SendDueRemindersWorker
  include Sidekiq::Job

  queue_as :default

  def perform(*args)
    Rails.logger.info "Running reminders worker..."
    user_notes = DueNotes.call

    return if user_notes.blank?

    user_notes.each do |user_id, notes|
      reminder_ids = notes.map(&:reminder_id).uniq
      raw_contents = notes.map(&:raw_content)

      ReminderMailer
        .with(user: user_id, notes: raw_contents, reminders: reminder_ids)
        .due_notes_email
        .deliver_later
    end

    Rails.logger.info "Reminders worker run completed."
  end
end
