# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestDistributedConnectionHandling < Test::Unit::TestCase

  include Helper::Distributed

  def test_ping
    assert_equal ["PONG"], r.ping
  end

  def test_select
    r.set "foo", "bar"

    r.select 14
    assert_equal nil, r.get("foo")

    r.select 15

    assert_equal "bar", r.get("foo")
  end
end
