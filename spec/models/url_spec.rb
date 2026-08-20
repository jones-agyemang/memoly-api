require 'rails_helper'

RSpec.describe Url, type: :model do
  describe 'validations' do
    # it { is_expected.to validate_inclusion_of(:source_type).in_array(%w[url]) }

    context "when URL is invalid" do
      it "rejects sources with invalid URI" do
        url_source = build(:url_source, source: "hxpt://www.example.com")

        url_source.valid?

        expect(url_source.errors.full_messages).to include("Source type protocol 'hxpt' is not permitted")
      end
    end
  end

  describe 'source URL' do
    it 'exposes the persisted source as the original URL' do
      source_intake = build(:url_source)

      expect(source_intake.original_url).to eq(source_intake.source)
    end
  end
end
