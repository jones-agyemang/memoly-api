require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:notes) }
  it { is_expected.to have_one(:authentication_code) }
  it { is_expected.to have_many(:collections) }

  it { should validate_uniqueness_of(:email) }
end
