require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:notes) }
  it { is_expected.to have_one(:authentication_code) }
  it { is_expected.to have_many(:collections) }

  it { should validate_uniqueness_of(:email) }

  describe "default collection" do
    it "creates a collection for the new user" do
      expect { described_class.create!(email: "text@example.com") }
        .to change(Collection, :count).by(1)
    end
  end
end
