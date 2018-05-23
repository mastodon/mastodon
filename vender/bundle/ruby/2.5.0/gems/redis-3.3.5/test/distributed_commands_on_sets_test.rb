# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))
require "lint/sets"

class TestDistributedCommandsOnSets < Test::Unit::TestCase

  include Helper::Distributed
  include Lint::Sets

  def test_smove
    assert_raise Redis::Distributed::CannotDistribute do
      r.sadd "foo", "s1"
      r.sadd "bar", "s2"

      r.smove("foo", "bar", "s1")
    end
  end

  def test_sinter
    assert_raise Redis::Distributed::CannotDistribute do
      r.sadd "foo", "s1"
      r.sadd "foo", "s2"
      r.sadd "bar", "s2"

      r.sinter("foo", "bar")
    end
  end

  def test_sinterstore
    assert_raise Redis::Distributed::CannotDistribute do
      r.sadd "foo", "s1"
      r.sadd "foo", "s2"
      r.sadd "bar", "s2"

      r.sinterstore("baz", "foo", "bar")
    end
  end

  def test_sunion
    assert_raise Redis::Distributed::CannotDistribute do
      r.sadd "foo", "s1"
      r.sadd "foo", "s2"
      r.sadd "bar", "s2"
      r.sadd "bar", "s3"

      r.sunion("foo", "bar")
    end
  end

  def test_sunionstore
    assert_raise Redis::Distributed::CannotDistribute do
      r.sadd "foo", "s1"
      r.sadd "foo", "s2"
      r.sadd "bar", "s2"
      r.sadd "bar", "s3"

      r.sunionstore("baz", "foo", "bar")
    end
  end

  def test_sdiff
    assert_raise Redis::Distributed::CannotDistribute do
      r.sadd "foo", "s1"
      r.sadd "foo", "s2"
      r.sadd "bar", "s2"
      r.sadd "bar", "s3"

      r.sdiff("foo", "bar")
    end
  end

  def test_sdiffstore
    assert_raise Redis::Distributed::CannotDistribute do
      r.sadd "foo", "s1"
      r.sadd "foo", "s2"
      r.sadd "bar", "s2"
      r.sadd "bar", "s3"

      r.sdiffstore("baz", "foo", "bar")
    end
  end
end
