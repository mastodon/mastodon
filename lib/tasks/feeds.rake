namespace :feeds do

  desc "Removes all feeds from Redis, forcing a precompute on next request for each user"
  task clear: :environment do
    $redis.keys('feed:*').each { |key| $redis.del(key) }
  end

end
