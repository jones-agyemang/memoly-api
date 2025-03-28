require "rails_helper"

RSpec.describe "Cron scheduler" do
  let(:schedule_loader) { Sidekiq::Cron::ScheduleLoader.new }

  it "has a schedule file" do
    expect(schedule_loader).to have_schedule_file
  end
end
