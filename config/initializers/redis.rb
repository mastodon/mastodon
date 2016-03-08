$redis = Redis.new(host: ENV['REDIS_HOST'] || 'localhost', port: ENV['REDIS_PORT'] || 6379)
