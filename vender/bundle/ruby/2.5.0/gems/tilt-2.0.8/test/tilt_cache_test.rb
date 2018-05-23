require 'test_helper'
require 'tilt'

class TiltCacheTest < Minitest::Test
  setup { @cache = Tilt::Cache.new }

  test "caching with single simple argument to #fetch" do
    template = nil
    result = @cache.fetch('hello') { template = Tilt::StringTemplate.new {''} }
    assert_same template, result
    result = @cache.fetch('hello') { fail 'should be cached' }
    assert_same template, result
  end

  test "caching with multiple complex arguments to #fetch" do
    template = nil
    result = @cache.fetch('hello', {:foo => 'bar', :baz => 'bizzle'}) { template = Tilt::StringTemplate.new {''} }
    assert_same template, result
    result = @cache.fetch('hello', {:foo => 'bar', :baz => 'bizzle'}) { fail 'should be cached' }
    assert_same template, result
  end

  test "caching nil" do
    called = false
    result = @cache.fetch("blah") {called = true; nil}
    assert_equal true, called
    assert_nil result
    called = false
    result = @cache.fetch("blah") {called = true; :blah}
    assert_equal false, called
    assert_nil result
  end

  test "clearing the cache with #clear" do
    template, other = nil
    result = @cache.fetch('hello') { template = Tilt::StringTemplate.new {''} }
    assert_same template, result

    @cache.clear
    result = @cache.fetch('hello') { other = Tilt::StringTemplate.new {''} }
    assert_same other, result
  end
end
