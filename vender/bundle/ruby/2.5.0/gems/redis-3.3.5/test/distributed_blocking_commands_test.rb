# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))
require "lint/blocking_commands"

class TestDistributedBlockingCommands < Test::Unit::TestCase

  include Helper::Distributed
  include Lint::BlockingCommands

  def test_blpop_raises
    assert_raises(Redis::Distributed::CannotDistribute) do
      r.blpop(["foo", "bar"])
    end
  end

  def test_blpop_raises_with_old_prototype
    assert_raises(Redis::Distributed::CannotDistribute) do
      r.blpop("foo", "bar", 0)
    end
  end

  def test_brpop_raises
    assert_raises(Redis::Distributed::CannotDistribute) do
      r.brpop(["foo", "bar"])
    end
  end

  def test_brpop_raises_with_old_prototype
    assert_raises(Redis::Distributed::CannotDistribute) do
      r.brpop("foo", "bar", 0)
    end
  end

  def test_brpoplpush_raises
    assert_raises(Redis::Distributed::CannotDistribute) do
      r.brpoplpush("foo", "bar")
    end
  end

  def test_brpoplpush_raises_with_old_prototype
    assert_raises(Redis::Distributed::CannotDistribute) do
      r.brpoplpush("foo", "bar", 0)
    end
  end
end
