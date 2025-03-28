require 'rails_helper'

RSpec.describe Note, type: :model do
  it { should have_many(:reminders).dependent(:destroy) }

  it "generates default reminders" do
    note = described_class.create(raw_content: "Lorem ipsum")

    expect(note.reminders.count).to eq(5)
  end
end
