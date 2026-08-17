require 'rails_helper'

RSpec.describe RawText, type: :model do
  describe ".validations" do
    it { is_expected.to validate_inclusion_of(:source_type).in_array(%w[raw_text]) }
  end
end
