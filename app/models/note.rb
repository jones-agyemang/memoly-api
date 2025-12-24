class Note < ApplicationRecord
  has_many :reminders, dependent: :destroy
  belongs_to :user
  belongs_to :collection

  DEFAULT_INTERVALS = [ 1, 3, 7, 14, 20 ] # DAYS

  after_create :generate_spaced_reminders

  before_validation :assign_user_from_collection, if: -> { collection.present? }

  def publicly_visible?
    public? && collection&.publicly_visible?
  end

  private

  def assign_user_from_collection
    self.user = collection.user
  end

  def generate_spaced_reminders
    DEFAULT_INTERVALS.each do |interval|
      reminders.create!(due_date: Time.zone.now + interval.days)
    end
  end
end
