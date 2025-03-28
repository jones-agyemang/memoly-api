class Note < ApplicationRecord
  has_many :reminders, dependent: :destroy

  DEFAULT_INTERVALS = [ 1, 3, 7, 14, 20 ] # DAYS

  after_create :generate_spaced_reminders

  private

  def generate_spaced_reminders
    DEFAULT_INTERVALS.each do |interval|
      reminders.create!(due_date: Time.zone.now + interval.days)
    end
  end
end
