# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:parent).class_name("Collection").optional(true) }
  it { is_expected.to have_many(:children).class_name("Collection").with_foreign_key(:parent_id).dependent(:destroy) }

  it { is_expected.to have_many(:notes) }

  describe "default collection" do
    let(:collection) { create(:collection, label:) }

    context "when it does not have the default label" do
      let(:label) { "Physics" }

      it "responds with false" do
        expect(collection.default?).to be_falsey
      end
    end

    context "when it has the default label" do
      let(:label) { Collection::DEFAULT_CATEGORY_LABEL }

      it "responds with true" do
        expect(collection.default?).to be_truthy
      end
    end
  end
end
