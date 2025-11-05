# frozen_string_literal: true

class DueNotes
  def self.call(date: Time.zone.today)
    new(date:).call
  end

  def initialize(date:)
    @date = date
  end

  def call
    Note
      .includes(:reminders, :user)
      .where(reminders: { completed: false, due_date: date.all_day })
      .references(:reminders, :user)
      .select("notes.id", "users.id AS user_id", "notes.raw_content", "reminders.id AS reminder_id")
      .distinct
      .group_by(&:user_id)
  end

  private

  attr_reader :date
end
