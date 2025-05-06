class Question < ApplicationRecord
  belongs_to :quiz

  validates :raw_content, presence: true
  validates :choices, presence: true
  validates :answer, presence: true
  validate :answer_included_in_choices

  private

  def answer_included_in_choices
    if answer.present? && choices.present? && !choices.include?(answer)
      errors.add(:answer, "must be included in the choices")
    end
  end
end
