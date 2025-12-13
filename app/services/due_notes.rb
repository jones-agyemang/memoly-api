# frozen_string_literal: true

class DueNotes
  def self.call(date: Time.zone.today, user_id:)
    new(date:, user_id:).call
  end

  def initialize(date:, user_id:)
    @date = date
    @user = User.find(user_id)
  end

  def call
    return fetch_user_notes if user

    fetch_user_grouped_notes
  end

  private

  attr_reader :date, :user

  def fetch_user_notes
    Note
      .joins(:collection, :reminders)
      .where(collection: { user_id: user.id }, reminders: { due_date: Time.zone.now.all_day })
      .select("notes.id", "notes.raw_content", "notes.source", "collection.label AS collection_label")
      .group_by(&:collection_label)
  end

  def fetch_user_grouped_notes
    Note
      .includes(:reminders, :user)
      .where(reminders: { completed: false, due_date: date.all_day })
      .references(:reminders, :user)
      .select("notes.id", "users.id AS user_id", "notes.raw_content", "reminders.id AS reminder_id")
      .distinct
      .group_by(&:user_id)
  end
end
