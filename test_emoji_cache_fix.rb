#!/usr/bin/env ruby

require_relative 'config/environment'

# Test case: create two emoji with case-differing shortcodes
emoji1_shortcode = 'blobhaj_mlem'
emoji2_shortcode = 'Blobhaj_Mlem'

puts 'Testing EntityCache key generation:'
puts "Emoji 1 key: #{EntityCache.instance.to_key(:emoji, emoji1_shortcode, 'mastodon.social')}"
puts "Emoji 2 key: #{EntityCache.instance.to_key(:emoji, emoji2_shortcode, 'mastodon.social')}"

puts "\nKeys are different: #{EntityCache.instance.to_key(:emoji, emoji1_shortcode, 'mastodon.social') != EntityCache.instance.to_key(:emoji, emoji2_shortcode, 'mastodon.social')}"

# Test backward compatibility for other cache types
puts "\nTesting backward compatibility:"
puts "Status key: #{EntityCache.instance.to_key(:status, 'https://Example.Com/test')}"
puts "Mention key: #{EntityCache.instance.to_key(:mention, 'TestUser', 'Example.Com')}"
