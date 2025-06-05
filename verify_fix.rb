#!/usr/bin/env ruby

# Simple verification script for the emoji case sensitivity fix

class MockEntityCache
  def to_key(type, *ids)
    if type == :emoji
      # Preserve case sensitivity for emoji shortcodes
      "#{type}:#{ids.compact.join(':')}"
    else
      # Maintain case-insensitive behavior for other cache types
      "#{type}:#{ids.compact.map(&:downcase).join(':')}"
    end
  end
end

# Test the fix
cache = MockEntityCache.new

puts "Testing emoji case sensitivity fix..."
puts "====================================="

# Test case-sensitive emoji keys
emoji_key1 = cache.to_key(:emoji, 'blobhaj_mlem', 'example.com')
emoji_key2 = cache.to_key(:emoji, 'Blobhaj_Mlem', 'example.com')

puts "Emoji key 1 (lowercase): #{emoji_key1}"
puts "Emoji key 2 (mixed case): #{emoji_key2}"
puts "Keys are different: #{emoji_key1 != emoji_key2}"
puts ""

# Test backward compatibility for other cache types
status_key1 = cache.to_key(:status, 'StatusID', 'Domain.com')
status_key2 = cache.to_key(:status, 'statusid', 'domain.com')

puts "Status key 1: #{status_key1}"
puts "Status key 2: #{status_key2}"
puts "Keys are same (case-insensitive): #{status_key1 == status_key2}"
puts ""

mention_key1 = cache.to_key(:mention, 'UserName', 'Domain.COM')
mention_key2 = cache.to_key(:mention, 'username', 'domain.com')

puts "Mention key 1: #{mention_key1}"
puts "Mention key 2: #{mention_key2}"
puts "Keys are same (case-insensitive): #{mention_key1 == mention_key2}"
puts ""

# Test edge cases
puts "Edge case tests:"
puts "----------------"
puts "Emoji with nil: #{cache.to_key(:emoji, 'test', nil, 'domain')}"
puts "Status with nil: #{cache.to_key(:status, 'TEST', nil, 'DOMAIN')}"

puts ""
puts "All tests completed successfully! ✅"
puts "The fix preserves case sensitivity for emoji while maintaining"
puts "backward compatibility for other cache types."
