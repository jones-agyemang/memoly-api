require 'rails_helper'

RSpec.describe Note, type: :model do
  it { should have_many(:reminders).dependent(:destroy) }
  it { is_expected.to belong_to(:user) }

  it "generates default reminders" do
    expect { create(:note) }.to change(Reminder, :count).by(Note::DEFAULT_INTERVALS.size)
  end
end
