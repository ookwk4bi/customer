Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://red-chl3o13hp8uej71i2sj0:6379' }
end
Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://red-chl3o13hp8uej71i2sj0:6379' }
end