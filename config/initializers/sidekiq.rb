require "sidekiq"

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "") }
  config.logger.level = Logger::DEBUG
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "") }
  config.logger.level = Logger::DEBUG
end
