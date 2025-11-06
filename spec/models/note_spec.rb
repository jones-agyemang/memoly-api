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
end
