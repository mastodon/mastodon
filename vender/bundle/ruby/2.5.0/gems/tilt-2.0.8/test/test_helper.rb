$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'bundler'
Bundler.setup

require 'minitest/autorun'
require 'minitest/mock'

# Contest adds +teardown+, +test+ and +context+ as class methods, and the
# instance methods +setup+ and +teardown+ now iterate on the corresponding
# blocks. Note that all setup and teardown blocks must be defined with the
# block syntax. Adding setup or teardown instance methods defeats the purpose
# of this library.
class Minitest::Test
  def self.setup(&block)
    define_method :setup do
      super(&block)
      instance_eval(&block)
    end
  end

  def self.teardown(&block)
    define_method :teardown do
      instance_eval(&block)
      super(&block)
    end
  end

  def self.context(name, &block)
    subclass = Class.new(self)
    remove_tests(subclass)
    subclass.class_eval(&block) if block_given?
    const_set(context_name(name), subclass)
  end

  def self.test(name, &block)
    define_method(test_name(name), &block)
  end

  class << self
    alias_method :should, :test
    alias_method :describe, :context
  end

private

  def self.context_name(name)
    "Test#{sanitize_name(name).gsub(/(^| )(\w)/) { $2.upcase }}".to_sym
  end

  def self.test_name(name)
    "test_#{sanitize_name(name).gsub(/\s+/,'_')}".to_sym
  end

  def self.sanitize_name(name)
    name.gsub(/\W+/, ' ').strip
  end

  def self.remove_tests(subclass)
    subclass.public_instance_methods.grep(/^test_/).each do |meth|
      subclass.send(:undef_method, meth.to_sym)
    end
  end
end
