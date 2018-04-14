# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestDistributedKeyTags < Test::Unit::TestCase

  include Helper
  include Helper::Distributed

  def test_hashes_consistently
    r1 = Redis::Distributed.new ["redis://localhost:#{PORT}/15", *NODES]
    r2 = Redis::Distributed.new ["redis://localhost:#{PORT}/15", *NODES]
    r3 = Redis::Distributed.new ["redis://localhost:#{PORT}/15", *NODES]

    assert_equal r1.node_for("foo").id, r2.node_for("foo").id
    assert_equal r1.node_for("foo").id, r3.node_for("foo").id
  end

  def test_allows_clustering_of_keys
    r = Redis::Distributed.new(NODES)
    r.add_node("redis://127.0.0.1:#{PORT}/14")
    r.flushdb

    100.times do |i|
      r.set "{foo}users:#{i}", i
    end

    assert_equal [0, 100], r.nodes.map { |node| node.keys.size }
  end

  def test_distributes_keys_if_no_clustering_is_used
    r.add_node("redis://127.0.0.1:#{PORT}/14")
    r.flushdb

    r.set "users:1", 1
    r.set "users:4", 4

    assert_equal [1, 1], r.nodes.map { |node| node.keys.size }
  end

  def test_allows_passing_a_custom_tag_extractor
    r = Redis::Distributed.new(NODES, :tag => /^(.+?):/)
    r.add_node("redis://127.0.0.1:#{PORT}/14")
    r.flushdb

    100.times do |i|
      r.set "foo:users:#{i}", i
    end

    assert_equal [0, 100], r.nodes.map { |node| node.keys.size }
  end
end
