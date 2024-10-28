if Rails.env.development?
  Sidekiq.configure_server do |config|
    if ENV['REDIS_HOST'].blank?
      $stderr.puts "Your .env file is empty. Make sure REDIS_HOST is set properly"
      exit 1
    end
    config.redis = {
      host: ENV['REDIS_HOST'],
      port: ENV['REDIS_PORT'] || '6379'
    }
  end
end
