#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

def test_scoring_system
  redis = Redis.new
  
  # Use specific test account
  test_account = Account.find_by(id: 113516414506051830)
  return puts "Account not found" unless test_account
  
  puts "Testing with account: #{test_account.acct} (ID: #{test_account.id})"
  
  # Get some recent statuses
  recent_statuses = Status.order(created_at: :desc).limit(5)
  return puts "No statuses found" if recent_statuses.empty?
  
  puts "\n=== Testing Scoring System ==="
  
  # Test 1: Check current feed state
  feed_key = "feed:home:#{test_account.id}"
  puts "\nCurrent feed state:"
  current_items = redis.zrevrange(feed_key, 0, -1, with_scores: true)
  puts "Items in feed: #{current_items.size}"
  
  # Test 2: Test score fetching
  puts "\nTesting score fetching:"
  recent_statuses.each do |status|
    score = redis.zscore(feed_key, status.id)
    puts "Status #{status.id}: #{score || 'no score'}"
  end
  
  # Test 3: Test score updates
  puts "\nTesting score updates:"
  test_status = recent_statuses.first
  new_score = rand(1000) / 100.0
  
  puts "Updating score for status #{test_status.id} to #{new_score}"
  redis.zadd(feed_key, new_score, test_status.id)
  
  # Verify update
  updated_score = redis.zscore(feed_key, test_status.id)
  puts "Updated score: #{updated_score}"
  
  # Test 4: Test pagination with scores
  puts "\nTesting pagination with scores:"
  test_pagination_with_scores(redis, feed_key)
  
  # Test 5: Test score-based ordering
  puts "\nTesting score-based ordering:"
  test_score_ordering(redis, feed_key)
end

def test_pagination_with_scores(redis, feed_key)
  # Get first page
  first_page = redis.zrevrange(feed_key, 0, 9, with_scores: true)
  return if first_page.empty?
  
  puts "First page scores:"
  first_page.each do |id, score|
    puts "ID: #{id}, Score: #{score}"
  end
  
  # Get second page using score-based pagination
  last_score = first_page.last.last
  second_page = redis.zrevrangebyscore(feed_key, "(#{last_score}", "-inf", limit: [0, 10], with_scores: true)
  
  puts "\nSecond page scores:"
  second_page.each do |id, score|
    puts "ID: #{id}, Score: #{score}"
  end
end

def test_score_ordering(redis, feed_key)
  # Get all items with scores
  items = redis.zrevrange(feed_key, 0, -1, with_scores: true)
  return if items.empty?
  
  # Verify ordering
  scores = items.map(&:last)
  is_ordered = scores.each_cons(2).all? { |a, b| a >= b }
  
  puts "Items are #{is_ordered ? 'correctly' : 'incorrectly'} ordered by score"
  
  # Show score distribution
  puts "\nScore distribution:"
  score_counts = scores.group_by(&:itself).transform_values(&:count)
  score_counts.sort_by { |score, _| -score }.each do |score, count|
    puts "Score #{score}: #{count} items"
  end
end

# Run the tests
test_scoring_system 