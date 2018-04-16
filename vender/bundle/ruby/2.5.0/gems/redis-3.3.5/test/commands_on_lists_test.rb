# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))
require "lint/lists"

class TestCommandsOnLists < Test::Unit::TestCase

  include Helper::Client
  include Lint::Lists

  def test_rpoplpush
    r.rpush "foo", "s1"
    r.rpush "foo", "s2"

    assert_equal "s2", r.rpoplpush("foo", "bar")
    assert_equal ["s2"], r.lrange("bar", 0, -1)
    assert_equal "s1", r.rpoplpush("foo", "bar")
    assert_equal ["s1", "s2"], r.lrange("bar", 0, -1)
  end
end
