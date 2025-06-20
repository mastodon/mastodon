#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

def inspect_feed(account_id)
  redis = Redis.new
  feed_key = "feed:home:#{account_id}"
  
  puts "Inspecting feed for account #{account_id}"
  puts "Feed key: #{feed_key}"
  
  # Get all members with scores
  members_with_scores = redis.zrange(feed_key, 0, -1, withscores: true)
  
  puts "\nFeed structure:"
  puts "Total items: #{members_with_scores.length}"
  
  # Get first 5 items with scores
  puts "\nFirst 5 items:"
  members_with_scores.first(5).each do |status_id, score|
    status = Status.find_by(id: status_id)
    puts "Status ID: #{status_id}"
    puts "Score: #{score}"
    puts "Created at: #{status&.created_at}"
    puts "Text: #{status&.text&.truncate(50)}"
    puts "---"
  end
  
  # Get last 5 items with scores
  puts "\nLast 5 items:"
  members_with_scores.last(5).each do |status_id, score|
    status = Status.find_by(id: status_id)
    puts "Status ID: #{status_id}"
    puts "Score: #{score}"
    puts "Created at: #{status&.created_at}"
    puts "Text: #{status&.text&.truncate(50)}"
    puts "---"
  end
  
  # Check pagination parameters
  puts "\nTesting pagination parameters:"
  first_id = members_with_scores.first[0]
  last_id = members_with_scores.last[0]
  middle_id = members_with_scores[members_with_scores.length/2][0]
  
  puts "First ID: #{first_id}"
  puts "Last ID: #{last_id}"
  puts "Middle ID: #{middle_id}"
  
  # Test ZRANGE with different ranges
  puts "\nTesting ZRANGE with different ranges:"
  puts "First 10 by score:"
  redis.zrange(feed_key, 0, 9, withscores: true).each do |id, score|
    puts "ID: #{id}, Score: #{score}"
  end
  
  puts "\nLast 10 by score:"
  redis.zrevrange(feed_key, 0, 9, withscores: true).each do |id, score|
    puts "ID: #{id}, Score: #{score}"
  end
end

# Example usage
account_id = ARGV[0] || 113516414506051830
inspect_feed(account_id) 