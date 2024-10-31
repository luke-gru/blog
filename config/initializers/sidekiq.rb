if Rails.env.development?
  Sidekiq.configure_server do |config|
    config.redis = {
      host: ENV['REDIS_HOST'] || 'localhost',
      port: ENV['REDIS_PORT'] || '6379'
    }
  end
end
