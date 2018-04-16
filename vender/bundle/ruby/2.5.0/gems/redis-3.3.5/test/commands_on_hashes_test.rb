# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))
require "lint/hashes"

class TestCommandsOnHashes < Test::Unit::TestCase

  include Helper::Client
  include Lint::Hashes

  def test_mapped_hmget_in_a_pipeline_returns_hash
    r.hset("foo", "f1", "s1")
    r.hset("foo", "f2", "s2")

    result = r.pipelined do
      r.mapped_hmget("foo", "f1", "f2")
    end

    assert_equal result[0], { "f1" => "s1", "f2" => "s2" }
  end
end
