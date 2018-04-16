require 'rubygems'
require 'minitest/unit'
require 'minitest/spec'
require 'minitest/autorun'
require 'rr'

require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "loofah"))

# require the ActionView helpers here, since they are no longer required automatically
require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "loofah", "helpers"))

puts "=> testing with Nokogiri #{Nokogiri::VERSION_INFO.inspect}"

class Loofah::TestCase < MiniTest::Spec
  class << self
    alias_method :context, :describe
  end
end
