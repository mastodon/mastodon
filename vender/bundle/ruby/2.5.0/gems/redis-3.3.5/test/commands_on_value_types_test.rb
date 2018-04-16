# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))
require "lint/value_types"

class TestCommandsOnValueTypes < Test::Unit::TestCase

  include Helper::Client
  include Lint::ValueTypes

  def test_del
    r.set "foo", "s1"
    r.set "bar", "s2"
    r.set "baz", "s3"

    assert_equal ["bar", "baz", "foo"], r.keys("*").sort

    assert_equal 1, r.del("foo")

    assert_equal ["bar", "baz"], r.keys("*").sort

    assert_equal 2, r.del("bar", "baz")

    assert_equal [], r.keys("*").sort
  end

  def test_del_with_array_argument
    r.set "foo", "s1"
    r.set "bar", "s2"
    r.set "baz", "s3"

    assert_equal ["bar", "baz", "foo"], r.keys("*").sort

    assert_equal 1, r.del(["foo"])

    assert_equal ["bar", "baz"], r.keys("*").sort

    assert_equal 2, r.del(["bar", "baz"])

    assert_equal [], r.keys("*").sort
  end

  def test_randomkey
    assert r.randomkey.to_s.empty?

    r.set("foo", "s1")

    assert_equal "foo", r.randomkey

    r.set("bar", "s2")

    4.times do
      assert ["foo", "bar"].include?(r.randomkey)
    end
  end

  def test_rename
    r.set("foo", "s1")
    r.rename "foo", "bar"

    assert_equal "s1", r.get("bar")
    assert_equal nil, r.get("foo")
  end

  def test_renamenx
    r.set("foo", "s1")
    r.set("bar", "s2")

    assert_equal false, r.renamenx("foo", "bar")

    assert_equal "s1", r.get("foo")
    assert_equal "s2", r.get("bar")
  end

  def test_dbsize
    assert_equal 0, r.dbsize

    r.set("foo", "s1")

    assert_equal 1, r.dbsize
  end

  def test_flushdb
    r.set("foo", "s1")
    r.set("bar", "s2")

    assert_equal 2, r.dbsize

    r.flushdb

    assert_equal 0, r.dbsize
  end

  def test_flushall
    redis_mock(:flushall => lambda { "+FLUSHALL" }) do |redis|
      assert_equal "FLUSHALL", redis.flushall
    end
  end

  def test_migrate
    redis_mock(:migrate => lambda { |*args| args }) do |redis|
      options = { :host => "127.0.0.1", :port => 1234 }

      ex = assert_raise(RuntimeError) do
        redis.migrate("foo", options.reject { |key, _| key == :host })
      end
      assert ex.message =~ /host not specified/

      ex = assert_raise(RuntimeError) do
        redis.migrate("foo", options.reject { |key, _| key == :port })
      end
      assert ex.message =~ /port not specified/

      default_db = redis.client.db.to_i
      default_timeout = redis.client.timeout.to_i

      # Test defaults
      actual = redis.migrate("foo", options)
      expected = ["127.0.0.1", "1234", "foo", default_db.to_s, default_timeout.to_s]
      assert_equal expected, actual

      # Test db override
      actual = redis.migrate("foo", options.merge(:db => default_db + 1))
      expected = ["127.0.0.1", "1234", "foo", (default_db + 1).to_s, default_timeout.to_s]
      assert_equal expected, actual

      # Test timeout override
      actual = redis.migrate("foo", options.merge(:timeout => default_timeout + 1))
      expected = ["127.0.0.1", "1234", "foo", default_db.to_s, (default_timeout + 1).to_s]
      assert_equal expected, actual
    end
  end
end
