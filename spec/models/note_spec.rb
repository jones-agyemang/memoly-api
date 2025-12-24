require 'rails_helper'

RSpec.describe Note, type: :model do
  it { should have_many(:reminders).dependent(:destroy) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:collection) }

  it "generates default reminders" do
    collection = create(:collection)

    expect { create(:note, collection:) }.to change(Reminder, :count).by(Note::DEFAULT_INTERVALS.size)
  end

  it "assigns the note user from the collection owner" do
    collection = create(:collection)
    note = build(:note, collection:, user: nil)

    note.validate

    expect(note.user).to eq(collection.user)
  end

  describe "#publicly_visible?" do
    let(:collection) { create(:collection, :public_collection) }

    it "returns true when note and collection are public" do
      note = build(:note, :public_note, collection:)

      expect(note.publicly_visible?).to be(true)
    end

    it "returns false when note is private" do
      note = build(:note, collection:, public: false)

      expect(note.publicly_visible?).to be(false)
    end

    it "returns false when collection is private" do
      private_collection = create(:collection, public: false)
      note = build(:note, :public_note, collection: private_collection)

      expect(note.publicly_visible?).to be(false)
    end
  end
end
