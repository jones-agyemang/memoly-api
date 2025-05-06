require 'rails_helper'

RSpec.describe Quiz, type: :model do
  subject(:quiz) { described_class.new }

  describe "associations" do
    it { is_expected.to have_many(:questions).dependent(:destroy) }
  end

  describe "validations" do
    it "is invalid without any questions" do
      expect(quiz.save).to be(true)
    end
  end
end
