#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

def test_pagination_behavior
  redis = Redis.new
  
  # Find a test account
  test_account = Account.first
  return puts "No accounts found" unless test_account
  
  puts "Testing with account: #{test_account.acct} (ID: #{test_account.id})"
  
  feed_key = "feed:home:#{test_account.id}"
  
  puts "\n=== Testing Pagination Behavior ==="
  
  # Test 1: Basic pagination
  puts "\nTest 1: Basic pagination"
  test_basic_pagination(redis, feed_key)
  
  # Test 2: Score-based pagination
  puts "\nTest 2: Score-based pagination"
  test_score_based_pagination(redis, feed_key)
  
  # Test 3: Edge cases
  puts "\nTest 3: Edge cases"
  test_edge_cases(redis, feed_key)
end

def test_basic_pagination(redis, feed_key)
  # Get first page
  first_page = redis.zrevrange(feed_key, 0, 9)
  return if first_page.empty?
  
  puts "First page IDs:"
  first_page.each { |id| puts id }
  
  # Get second page
  second_page = redis.zrevrange(feed_key, 10, 19)
  puts "\nSecond page IDs:"
  second_page.each { |id| puts id }
  
  # Verify no overlap
  overlap = first_page & second_page
  puts "\nOverlap between pages: #{overlap.size} items"
end

def test_score_based_pagination(redis, feed_key)
  # Get first page with scores
  first_page = redis.zrevrange(feed_key, 0, 9, with_scores: true)
  return if first_page.empty?
  
  puts "First page (with scores):"
  first_page.each do |id, score|
    puts "ID: #{id}, Score: #{score}"
  end
  
  # Get second page using score-based pagination
  last_score = first_page.last.last
  second_page = redis.zrevrangebyscore(feed_key, "(#{last_score}", "-inf", limit: [0, 10], with_scores: true)
  
  puts "\nSecond page (with scores):"
  second_page.each do |id, score|
    puts "ID: #{id}, Score: #{score}"
  end
  
  # Verify score ordering
  all_scores = (first_page + second_page).map(&:last)
  is_ordered = all_scores.each_cons(2).all? { |a, b| a >= b }
  puts "\nScores are #{is_ordered ? 'correctly' : 'incorrectly'} ordered"
end

def test_edge_cases(redis, feed_key)
  # Test empty feed
  empty_key = "feed:home:empty_test"
  puts "\nTesting empty feed:"
  empty_result = redis.zrevrange(empty_key, 0, 9)
  puts "Empty feed result: #{empty_result.inspect}"
  
  # Test feed with single item
  single_key = "feed:home:single_test"
  redis.zadd(single_key, 1.0, "test_id")
  puts "\nTesting feed with single item:"
  single_result = redis.zrevrange(single_key, 0, 9)
  puts "Single item result: #{single_result.inspect}"
  
  # Test feed with duplicate scores
  duplicate_key = "feed:home:duplicate_test"
  redis.zadd(duplicate_key, 1.0, "id1")
  redis.zadd(duplicate_key, 1.0, "id2")
  puts "\nTesting feed with duplicate scores:"
  duplicate_result = redis.zrevrange(duplicate_key, 0, 9, with_scores: true)
  puts "Duplicate scores result:"
  duplicate_result.each do |id, score|
    puts "ID: #{id}, Score: #{score}"
  end
end

# Run the tests
test_pagination_behavior 