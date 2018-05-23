# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))
require "lint/value_types"

class TestDistributedCommandsOnValueTypes < Test::Unit::TestCase

  include Helper::Distributed
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
    assert_raise Redis::Distributed::CannotDistribute do
      r.randomkey
    end
  end

  def test_rename
    assert_raise Redis::Distributed::CannotDistribute do
      r.set("foo", "s1")
      r.rename "foo", "bar"
    end

    assert_equal "s1", r.get("foo")
    assert_equal nil, r.get("bar")
  end

  def test_renamenx
    assert_raise Redis::Distributed::CannotDistribute do
      r.set("foo", "s1")
      r.rename "foo", "bar"
    end

    assert_equal "s1", r.get("foo")
    assert_equal nil , r.get("bar")
  end

  def test_dbsize
    assert_equal [0], r.dbsize

    r.set("foo", "s1")

    assert_equal [1], r.dbsize
  end

  def test_flushdb
    r.set("foo", "s1")
    r.set("bar", "s2")

    assert_equal [2], r.dbsize

    r.flushdb

    assert_equal [0], r.dbsize
  end

  def test_migrate
    r.set("foo", "s1")

    assert_raise Redis::Distributed::CannotDistribute do
      r.migrate("foo", {})
    end
  end
end
