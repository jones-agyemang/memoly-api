class SendDueRemindersWorker
  include Sidekiq::Job

  queue_as :default

  def perform(*args)
    Rails.logger.info "Running reminders worker..."

    user_notes = Note
      .includes(:reminders, :user)
      .where(reminders: { completed: false, due_date: Date.today.all_day })
      .references(:reminders, :user)
      .select("notes.id", "users.id AS user_id", "notes.raw_content", "reminders.id AS reminder_id")
      .distinct
      .group_by(&:user_id)

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
