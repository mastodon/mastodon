# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))
require "lint/hyper_log_log"

class TestDistributedCommandsOnHyperLogLog < Test::Unit::TestCase

  include Helper::Distributed
  include Lint::HyperLogLog

  def test_pfmerge
    target_version "2.8.9" do
      assert_raise Redis::Distributed::CannotDistribute do
        r.pfadd "foo", "s1"
        r.pfadd "bar", "s2"

        assert r.pfmerge("res", "foo", "bar")
      end
    end
  end

  def test_pfcount_multiple_keys_diff_nodes
    target_version "2.8.9" do
      assert_raise Redis::Distributed::CannotDistribute do
        r.pfadd "foo", "s1"
        r.pfadd "bar", "s2"

        assert r.pfcount("res", "foo", "bar")
      end
    end
  end

end
