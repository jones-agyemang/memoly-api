require 'rails_helper'

RSpec.describe Question, type: :model do
  subject(:question) { create(:question) }

  describe "association" do
    it { is_expected.to belong_to(:quiz) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:raw_content) }
    it { is_expected.to validate_presence_of(:choices) }
    it { is_expected.to validate_presence_of(:answer) }

    it "is valid with valid attributes" do
      expect(question.valid?).to be true
    end

    it "is invalid when answer is not in choices" do
      question.answer = "None of the above"
      expect(question.valid?).to be false
      expect(question.errors[:answer]).to include("must be included in the choices")
    end
  end

  describe "serialization" do
    it "serializes choices as an array" do
      question.save
      question.reload
      expect(question.choices).to be_an(Array)
      expect(question.choices).to eq([ "A programming language", "A gemstone", "Both" ])
    end
  end
end
