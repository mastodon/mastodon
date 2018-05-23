# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))
require "lint/hyper_log_log"

class TestCommandsOnHyperLogLog < Test::Unit::TestCase

  include Helper::Client
  include Lint::HyperLogLog

  def test_pfmerge
    target_version "2.8.9" do
      r.pfadd "foo", "s1"
      r.pfadd "bar", "s2"

      assert_equal true, r.pfmerge("res", "foo", "bar")
      assert_equal 2, r.pfcount("res")
    end
  end

end