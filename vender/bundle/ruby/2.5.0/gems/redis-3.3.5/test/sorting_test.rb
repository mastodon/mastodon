# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestSorting < Test::Unit::TestCase

  include Helper::Client

  def test_sort
    r.set("foo:1", "s1")
    r.set("foo:2", "s2")

    r.rpush("bar", "1")
    r.rpush("bar", "2")

    assert_equal ["s1"], r.sort("bar", :get => "foo:*", :limit => [0, 1])
    assert_equal ["s2"], r.sort("bar", :get => "foo:*", :limit => [0, 1], :order => "desc alpha")
  end

  def test_sort_with_an_array_of_gets
    r.set("foo:1:a", "s1a")
    r.set("foo:1:b", "s1b")

    r.set("foo:2:a", "s2a")
    r.set("foo:2:b", "s2b")

    r.rpush("bar", "1")
    r.rpush("bar", "2")

    assert_equal [["s1a", "s1b"]], r.sort("bar", :get => ["foo:*:a", "foo:*:b"], :limit => [0, 1])
    assert_equal [["s2a", "s2b"]], r.sort("bar", :get => ["foo:*:a", "foo:*:b"], :limit => [0, 1], :order => "desc alpha")
    assert_equal [["s1a", "s1b"], ["s2a", "s2b"]], r.sort("bar", :get => ["foo:*:a", "foo:*:b"])
  end

  def test_sort_with_store
    r.set("foo:1", "s1")
    r.set("foo:2", "s2")

    r.rpush("bar", "1")
    r.rpush("bar", "2")

    r.sort("bar", :get => "foo:*", :store => "baz")
    assert_equal ["s1", "s2"], r.lrange("baz", 0, -1)
  end

  def test_sort_with_an_array_of_gets_and_with_store
    r.set("foo:1:a", "s1a")
    r.set("foo:1:b", "s1b")

    r.set("foo:2:a", "s2a")
    r.set("foo:2:b", "s2b")

    r.rpush("bar", "1")
    r.rpush("bar", "2")

    r.sort("bar", :get => ["foo:*:a", "foo:*:b"], :store => 'baz')
    assert_equal ["s1a", "s1b", "s2a", "s2b"], r.lrange("baz", 0, -1)
  end
end
