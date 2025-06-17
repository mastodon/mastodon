#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

def inspect_feed(account_id)
  redis = Redis.new
  feed_key = "feed:home:#{account_id}"
  
  puts "\n=== Feed Structure Inspection ==="
  puts "Feed key: #{feed_key}"
  
  # Get total number of items
  total_items = redis.zcard(feed_key)
  puts "\nTotal items in feed: #{total_items}"
  
  # Get a sample of items with their scores
  sample_size = [total_items, 10].min
  puts "\nSample of #{sample_size} items with scores:"
  items_with_scores = redis.zrevrange(feed_key, 0, sample_size - 1, with_scores: true)
  
  items_with_scores.each do |status_id, score|
    status = Status.find_by(id: status_id)
    if status
      puts "Status ID: #{status_id}"
      puts "Score: #{score}"
      puts "Created at: #{status.created_at}"
      puts "Account: #{status.account.acct}"
      puts "Text: #{status.text[0..100]}..."
      puts "---"
    else
      puts "Status ID: #{status_id} (not found in database)"
      puts "Score: #{score}"
      puts "---"
    end
  end
  
  # Check score distribution
  puts "\nScore Distribution:"
  min_score = redis.zrange(feed_key, 0, 0, with_scores: true).first&.last
  max_score = redis.zrevrange(feed_key, 0, 0, with_scores: true).first&.last
  
  puts "Min score: #{min_score}"
  puts "Max score: #{max_score}"
  
  # Check for any anomalies
  puts "\nChecking for potential issues:"
  
  # Check for duplicate scores
  all_scores = redis.zrange(feed_key, 0, -1, with_scores: true).map(&:last)
  score_counts = all_scores.group_by(&:itself).transform_values(&:count)
  duplicates = score_counts.select { |_, count| count > 1 }
  
  if duplicates.any?
    puts "Found #{duplicates.size} scores with multiple statuses:"
    duplicates.each do |score, count|
      puts "Score #{score} appears #{count} times"
    end
  else
    puts "No duplicate scores found"
  end
  
  # Check for missing statuses
  status_ids = redis.zrange(feed_key, 0, -1)
  missing_statuses = status_ids.count { |id| !Status.exists?(id) }
  puts "Found #{missing_statuses} status IDs in Redis that don't exist in database"
  
  # Check pagination behavior
  puts "\nTesting pagination behavior:"
  test_pagination(redis, feed_key)
end

def test_pagination(redis, feed_key)
  # Get first page
  first_page = redis.zrevrange(feed_key, 0, 9, with_scores: true)
  return if first_page.empty?
  
  puts "\nFirst page (10 items):"
  first_page.each do |status_id, score|
    puts "ID: #{status_id}, Score: #{score}"
  end
  
  # Get second page using score-based pagination
  last_score = first_page.last.last
  second_page = redis.zrevrangebyscore(feed_key, "(#{last_score}", "-inf", limit: [0, 10], with_scores: true)
  
  puts "\nSecond page (10 items):"
  second_page.each do |status_id, score|
    puts "ID: #{status_id}, Score: #{score}"
  end
  
  # Verify ordering
  puts "\nVerifying ordering:"
  all_scores = (first_page + second_page).map(&:last)
  is_ordered = all_scores.each_cons(2).all? { |a, b| a >= b }
  puts "Scores are #{is_ordered ? 'correctly' : 'incorrectly'} ordered"
end

# Find a suitable test account
test_account = Account.find_by(id: 113516414506051830)
if test_account
  puts "Testing with account: #{test_account.acct} (ID: #{test_account.id})"
  inspect_feed(test_account.id)
else
  puts "Account not found"
end 