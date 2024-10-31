if Rails.env.development?
  Sidekiq.configure_server do |config|
    config.redis = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/0",
    }
  end
  Sidekiq.configure_client do |config|
    config.redis = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/0",
    }
  end
elsif Rails.env.production?
  Sidekiq.configure_server do |config|
    if ENV['REDIS_HOST'].blank?
      $stderr.puts "no redis host set!"
      exit 1
    end
    config.redis = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/0",
    }
  end
  Sidekiq.configure_client do |config|
    config.redis = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/0",
    }
  end
end
