require 'rails_helper'

RSpec.describe SourceIntake, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:source_type) }
    it { is_expected.to validate_presence_of(:source) }
    it { is_expected.to validate_inclusion_of(:source_type).in_array(%w[url]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
