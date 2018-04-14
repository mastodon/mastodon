# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))
require "lint/sorted_sets"

class TestCommandsOnSortedSets < Test::Unit::TestCase

  include Helper::Client
  include Lint::SortedSets

  def test_zrangebylex
    target_version "2.8.9" do
      r.zadd "foo", 0, "aaren"
      r.zadd "foo", 0, "abagael"
      r.zadd "foo", 0, "abby"
      r.zadd "foo", 0, "abbygail"

      assert_equal ["aaren", "abagael", "abby", "abbygail"], r.zrangebylex("foo", "[a", "[a\xff")
      assert_equal ["aaren", "abagael"], r.zrangebylex("foo", "[a", "[a\xff", :limit => [0, 2])
      assert_equal ["abby", "abbygail"], r.zrangebylex("foo", "(abb", "(abb\xff")
      assert_equal ["abbygail"], r.zrangebylex("foo", "(abby", "(abby\xff")
    end
  end

  def test_zrevrangebylex
    target_version "2.9.9" do
      r.zadd "foo", 0, "aaren"
      r.zadd "foo", 0, "abagael"
      r.zadd "foo", 0, "abby"
      r.zadd "foo", 0, "abbygail"

      assert_equal ["abbygail", "abby", "abagael", "aaren"], r.zrevrangebylex("foo", "[a\xff", "[a")
      assert_equal ["abbygail", "abby"], r.zrevrangebylex("foo", "[a\xff", "[a", :limit => [0, 2])
      assert_equal ["abbygail", "abby"], r.zrevrangebylex("foo", "(abb\xff", "(abb")
      assert_equal ["abbygail"], r.zrevrangebylex("foo", "(abby\xff", "(abby")
    end
  end

  def test_zcount
    r.zadd "foo", 1, "s1"
    r.zadd "foo", 2, "s2"
    r.zadd "foo", 3, "s3"

    assert_equal 2, r.zcount("foo", 2, 3)
  end

  def test_zunionstore
    r.zadd "foo", 1, "s1"
    r.zadd "bar", 2, "s2"
    r.zadd "foo", 3, "s3"
    r.zadd "bar", 4, "s4"

    assert_equal 4, r.zunionstore("foobar", ["foo", "bar"])
    assert_equal ["s1", "s2", "s3", "s4"], r.zrange("foobar", 0, -1)
  end

  def test_zunionstore_with_weights
    r.zadd "foo", 1, "s1"
    r.zadd "foo", 3, "s3"
    r.zadd "bar", 20, "s2"
    r.zadd "bar", 40, "s4"

    assert_equal 4, r.zunionstore("foobar", ["foo", "bar"])
    assert_equal ["s1", "s3", "s2", "s4"], r.zrange("foobar", 0, -1)

    assert_equal 4, r.zunionstore("foobar", ["foo", "bar"], :weights => [10, 1])
    assert_equal ["s1", "s2", "s3", "s4"], r.zrange("foobar", 0, -1)
  end

  def test_zunionstore_with_aggregate
    r.zadd "foo", 1, "s1"
    r.zadd "foo", 2, "s2"
    r.zadd "bar", 4, "s2"
    r.zadd "bar", 3, "s3"

    assert_equal 3, r.zunionstore("foobar", ["foo", "bar"])
    assert_equal ["s1", "s3", "s2"], r.zrange("foobar", 0, -1)

    assert_equal 3, r.zunionstore("foobar", ["foo", "bar"], :aggregate => :min)
    assert_equal ["s1", "s2", "s3"], r.zrange("foobar", 0, -1)

    assert_equal 3, r.zunionstore("foobar", ["foo", "bar"], :aggregate => :max)
    assert_equal ["s1", "s3", "s2"], r.zrange("foobar", 0, -1)
  end

  def test_zinterstore
    r.zadd "foo", 1, "s1"
    r.zadd "bar", 2, "s1"
    r.zadd "foo", 3, "s3"
    r.zadd "bar", 4, "s4"

    assert_equal 1, r.zinterstore("foobar", ["foo", "bar"])
    assert_equal ["s1"], r.zrange("foobar", 0, -1)
  end

  def test_zinterstore_with_weights
    r.zadd "foo", 1, "s1"
    r.zadd "foo", 2, "s2"
    r.zadd "foo", 3, "s3"
    r.zadd "bar", 20, "s2"
    r.zadd "bar", 30, "s3"
    r.zadd "bar", 40, "s4"

    assert_equal 2, r.zinterstore("foobar", ["foo", "bar"])
    assert_equal ["s2", "s3"], r.zrange("foobar", 0, -1)

    assert_equal 2, r.zinterstore("foobar", ["foo", "bar"], :weights => [10, 1])
    assert_equal ["s2", "s3"], r.zrange("foobar", 0, -1)

    assert_equal 40.0, r.zscore("foobar", "s2")
    assert_equal 60.0, r.zscore("foobar", "s3")
  end

  def test_zinterstore_with_aggregate
    r.zadd "foo", 1, "s1"
    r.zadd "foo", 2, "s2"
    r.zadd "foo", 3, "s3"
    r.zadd "bar", 20, "s2"
    r.zadd "bar", 30, "s3"
    r.zadd "bar", 40, "s4"

    assert_equal 2, r.zinterstore("foobar", ["foo", "bar"])
    assert_equal ["s2", "s3"], r.zrange("foobar", 0, -1)
    assert_equal 22.0, r.zscore("foobar", "s2")
    assert_equal 33.0, r.zscore("foobar", "s3")

    assert_equal 2, r.zinterstore("foobar", ["foo", "bar"], :aggregate => :min)
    assert_equal ["s2", "s3"], r.zrange("foobar", 0, -1)
    assert_equal 2.0, r.zscore("foobar", "s2")
    assert_equal 3.0, r.zscore("foobar", "s3")

    assert_equal 2, r.zinterstore("foobar", ["foo", "bar"], :aggregate => :max)
    assert_equal ["s2", "s3"], r.zrange("foobar", 0, -1)
    assert_equal 20.0, r.zscore("foobar", "s2")
    assert_equal 30.0, r.zscore("foobar", "s3")
  end
end
