# frozen_string_literal: true

class DueNotes
  def self.call(date: Time.zone.today, user_id: nil, include_completed: false)
    new(date:, user_id:, include_completed:).call
  end

  def initialize(date:, user_id:, include_completed:)
    @date = date
    @user = build_user(user_id)
    @include_completed = include_completed
  end

  def call
    return fetch_user_notes if user.present?

    fetch_user_grouped_notes
  end

  private

  attr_reader :date, :user, :include_completed

  def build_user(user_id)
    return if user_id.blank?

    User.find(user_id)
  end

  def fetch_user_notes
    Note
      .joins(:collection, :reminders)
      .where(collections: { user_id: user.id }, reminders: reminder_filters)
      .select("notes.id", "notes.raw_content", "notes.source", "collections.label AS collection_label")
      .group_by(&:collection_label)
  end

  def fetch_user_grouped_notes
    Note
      .includes(:reminders, :user)
      .where(reminders: reminder_filters)
      .references(:reminders, :user)
      .select("notes.id", "users.id AS user_id", "notes.raw_content", "reminders.id AS reminder_id")
      .distinct
      .group_by(&:user_id)
  end

  def date_range
    @date_range ||= date.all_day
  end

  def reminder_filters
    if include_completed
      { due_date: date_range }
    else
      { completed: false, due_date: date_range }
    end
  end
end
