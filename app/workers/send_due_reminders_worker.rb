class SendDueRemindersWorker
  include Sidekiq::Job

  queue_as :default

  def perform(*args)
    Rails.logger.info "Running reminders worker..."
    user_reminders = Note.includes(:reminders)
                         .where(reminders: { completed: false })
                         .references(:reminders)
                         .select(:id, :user_id, :raw_content, "reminders.id")
                         .distinct
                         .group_by(&:user_id)

    user_reminders = user_reminders.transform_values do |note|
      note.map(&:raw_content)
    end

    return unless user_reminders.any?

    user_reminders.each do |user_id, notes|
      ReminderMailer.with(user:, notes:, reminders:).due_notes_email.deliver_later
    end
    Rails.logger.info "Reminders worker run completed."
  end
end
