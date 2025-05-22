require "sidekiq"
require "sidekiq-cron"

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") }
  config.logger.level = Logger::DEBUG
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") }
  schedule_file = Rails.root.join("config/sidekiq.yml")

  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end

  config.logger.level = Logger::DEBUG
end
