require "sidekiq"

redis_cfg = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

Sidekiq.configure_client do |config|
  config.redis = redis_cfg
  config.logger.level = Logger::DEBUG
end

Sidekiq.configure_server do |config|
  config.redis = redis_cfg
  config.logger.level = Logger::DEBUG
end
