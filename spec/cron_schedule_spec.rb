require "rails_helper"

RSpec.describe "Cron scheduler" do
  let(:schedule_loader) { Sidekiq::Cron::ScheduleLoader.new }
  let(:schedule_path) { Rails.root.join("config/schedule.yml") }

  it "has a schedule file" do
    expect(schedule_loader).to have_schedule_file
  end

  it "does not schedule reminders when disabled" do
    schedule = YAML.load_file(schedule_path)

    expect(schedule).to be_a(Hash)
    expect(schedule).not_to include("send_due_reminders")
  end
end
