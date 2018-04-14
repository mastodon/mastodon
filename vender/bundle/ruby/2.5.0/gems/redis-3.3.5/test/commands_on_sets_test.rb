# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))
require "lint/sets"

class TestCommandsOnSets < Test::Unit::TestCase

  include Helper::Client
  include Lint::Sets

  def test_smove
    r.sadd "foo", "s1"
    r.sadd "bar", "s2"

    assert r.smove("foo", "bar", "s1")
    assert r.sismember("bar", "s1")
  end

  def test_sinter
    r.sadd "foo", "s1"
    r.sadd "foo", "s2"
    r.sadd "bar", "s2"

    assert_equal ["s2"], r.sinter("foo", "bar")
  end

  def test_sinterstore
    r.sadd "foo", "s1"
    r.sadd "foo", "s2"
    r.sadd "bar", "s2"

    r.sinterstore("baz", "foo", "bar")

    assert_equal ["s2"], r.smembers("baz")
  end

  def test_sunion
    r.sadd "foo", "s1"
    r.sadd "foo", "s2"
    r.sadd "bar", "s2"
    r.sadd "bar", "s3"

    assert_equal ["s1", "s2", "s3"], r.sunion("foo", "bar").sort
  end

  def test_sunionstore
    r.sadd "foo", "s1"
    r.sadd "foo", "s2"
    r.sadd "bar", "s2"
    r.sadd "bar", "s3"

    r.sunionstore("baz", "foo", "bar")

    assert_equal ["s1", "s2", "s3"], r.smembers("baz").sort
  end

  def test_sdiff
    r.sadd "foo", "s1"
    r.sadd "foo", "s2"
    r.sadd "bar", "s2"
    r.sadd "bar", "s3"

    assert_equal ["s1"], r.sdiff("foo", "bar")
    assert_equal ["s3"], r.sdiff("bar", "foo")
  end

  def test_sdiffstore
    r.sadd "foo", "s1"
    r.sadd "foo", "s2"
    r.sadd "bar", "s2"
    r.sadd "bar", "s3"

    r.sdiffstore("baz", "foo", "bar")

    assert_equal ["s1"], r.smembers("baz")
  end
end
