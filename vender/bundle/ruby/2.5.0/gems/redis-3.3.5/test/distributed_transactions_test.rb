# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestDistributedTransactions < Test::Unit::TestCase

  include Helper::Distributed

  def test_multi_discard
    @foo = nil

    assert_raise Redis::Distributed::CannotDistribute do
      r.multi { @foo = 1 }
    end

    assert_equal nil, @foo

    assert_raise Redis::Distributed::CannotDistribute do
      r.discard
    end
  end

  def test_watch_unwatch
    assert_raise Redis::Distributed::CannotDistribute do
      r.watch("foo")
    end

    assert_raise Redis::Distributed::CannotDistribute do
      r.unwatch
    end
  end
end
