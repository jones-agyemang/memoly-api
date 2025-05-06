class Quiz < ApplicationRecord
  has_many :questions, dependent: :destroy

  accepts_nested_attributes_for :questions

  # validate :minimum_no_of_questions

  private

  # def minimum_no_of_questions
  #   if questions.empty?
  #     errors.add(:questions, "must include at least one")
  #   end
  # end
end
