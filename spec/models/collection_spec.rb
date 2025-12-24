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

  describe "hierarchy management" do
    let(:user) { create(:user) }

    it "updates descendant paths when parent path changes" do
      parent = create(:collection, user:, label: "Sciences")
      child = create(:collection, user:, parent:, label: "Chemistry")
      new_parent = create(:collection, user:, label: "STEM")

      parent.update!(parent: new_parent)

      expect(parent.reload.path).to eq("#{new_parent.reload.path}.sciences")
      expect(child.reload.path).to eq("#{parent.path}.chemistry")
    end

    it "does not allow assigning a collection to one of its descendants" do
      parent = create(:collection, user:, label: "Root")
      child = create(:collection, user:, parent:, label: "Child")

      parent.parent = child

      expect(parent).not_to be_valid
      expect(parent.errors[:parent_id]).to be_present
    end

    it "does not allow assigning a collection to a parent from another user" do
      parent = create(:collection, user:, label: "Root")
      other_parent = create(:collection, label: "Other Root")

      parent.parent = other_parent

      expect(parent).not_to be_valid
      expect(parent.errors[:parent_id]).to be_present
    end
  end

  describe "public visibility" do
    let(:user) { create(:user) }

    it "returns true when collection and ancestors are public" do
      parent = create(:collection, :public_collection, user:, label: "Library")
      child = create(:collection, :public_collection, user:, parent:, label: "Shelf A")

      expect(child.publicly_visible?).to be(true)
    end

    it "returns false when an ancestor is private" do
      parent = create(:collection, user:, label: "Private Library")
      child = create(:collection, :public_collection, user:, parent:, label: "Shelf B")

      expect(child.publicly_visible?).to be(false)
    end

    it "returns only public notes when collection is public" do
      collection = create(:collection, :public_collection, user:, label: "Highlights")
      public_note = create(:note, :public_note, collection:, raw_content: "Public snippet")
      create(:note, collection:, raw_content: "Hidden snippet")

      expect(collection.public_notes).to contain_exactly(public_note)
    end
  end
end
