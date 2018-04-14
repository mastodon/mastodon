# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))
require "lint/strings"

class TestDistributedCommandsOnStrings < Test::Unit::TestCase

  include Helper::Distributed
  include Lint::Strings

  def test_mget
    assert_raise Redis::Distributed::CannotDistribute do
      r.mget("foo", "bar")
    end
  end

  def test_mget_mapped
    assert_raise Redis::Distributed::CannotDistribute do
      r.mapped_mget("foo", "bar")
    end
  end

  def test_mset
    assert_raise Redis::Distributed::CannotDistribute do
      r.mset(:foo, "s1", :bar, "s2")
    end
  end

  def test_mset_mapped
    assert_raise Redis::Distributed::CannotDistribute do
      r.mapped_mset(:foo => "s1", :bar => "s2")
    end
  end

  def test_msetnx
    assert_raise Redis::Distributed::CannotDistribute do
      r.set("foo", "s1")
      r.msetnx(:foo, "s2", :bar, "s3")
    end
  end

  def test_msetnx_mapped
    assert_raise Redis::Distributed::CannotDistribute do
      r.set("foo", "s1")
      r.mapped_msetnx(:foo => "s2", :bar => "s3")
    end
  end

  def test_bitop
    target_version "2.5.10" do
      assert_raise Redis::Distributed::CannotDistribute do
        r.set("foo", "a")
        r.set("bar", "b")

        r.bitop(:and, "foo&bar", "foo", "bar")
      end
    end
  end
end
