require "sidekiq"
require "sidekiq-cron"

Sidekiq.configure_client do |config|
  config.logger.level = Logger::DEBUG
end

Sidekiq.configure_server do |config|
  # configure scheduler
  schedule_file = Rails.root.join("config/sidekiq.yml")

  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end

  # enable verbose logging
  config.logger.level = Logger::DEBUG
end
