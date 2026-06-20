require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to have_many(:notes) }
    it { is_expected.to have_one(:authentication_code) }
    it { is_expected.to have_many(:collections) }

    it { should validate_uniqueness_of(:email) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:source_intakes) }
  end

  describe "authorization" do
    it do
      should have_many(:access_grants).class_name("Doorkeeper::AccessGrant")
                                      .with_foreign_key(:resource_owner_id)
                                      .dependent(:delete_all)
    end
    it do
      should have_many(:access_tokens).class_name("Doorkeeper::AccessToken")
                                      .with_foreign_key(:resource_owner_id)
                                      .dependent(:delete_all)
    end
  end

  describe "default collection" do
    it "creates a collection for the new user" do
      expect { described_class.create!(email: "text@example.com") }
        .to change(Collection, :count).by(1)
    end
  end
end
