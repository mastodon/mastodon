# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestPipeliningCommands < Test::Unit::TestCase

  include Helper::Client

  def test_bulk_commands
    r.pipelined do
      r.lpush "foo", "s1"
      r.lpush "foo", "s2"
    end

    assert_equal 2, r.llen("foo")
    assert_equal "s2", r.lpop("foo")
    assert_equal "s1", r.lpop("foo")
  end

  def test_multi_bulk_commands
    r.pipelined do
      r.mset("foo", "s1", "bar", "s2")
      r.mset("baz", "s3", "qux", "s4")
    end

    assert_equal "s1", r.get("foo")
    assert_equal "s2", r.get("bar")
    assert_equal "s3", r.get("baz")
    assert_equal "s4", r.get("qux")
  end

  def test_bulk_and_multi_bulk_commands_mixed
    r.pipelined do
      r.lpush "foo", "s1"
      r.lpush "foo", "s2"
      r.mset("baz", "s3", "qux", "s4")
    end

    assert_equal 2, r.llen("foo")
    assert_equal "s2", r.lpop("foo")
    assert_equal "s1", r.lpop("foo")
    assert_equal "s3", r.get("baz")
    assert_equal "s4", r.get("qux")
  end

  def test_multi_bulk_and_bulk_commands_mixed
    r.pipelined do
      r.mset("baz", "s3", "qux", "s4")
      r.lpush "foo", "s1"
      r.lpush "foo", "s2"
    end

    assert_equal 2, r.llen("foo")
    assert_equal "s2", r.lpop("foo")
    assert_equal "s1", r.lpop("foo")
    assert_equal "s3", r.get("baz")
    assert_equal "s4", r.get("qux")
  end

  def test_pipelined_with_an_empty_block
    assert_nothing_raised do
      r.pipelined do
      end
    end

    assert_equal 0, r.dbsize
  end

  def test_returning_the_result_of_a_pipeline
    result = r.pipelined do
      r.set "foo", "bar"
      r.get "foo"
      r.get "bar"
    end

    assert_equal ["OK", "bar", nil], result
  end

  def test_assignment_of_results_inside_the_block
    r.pipelined do
      @first = r.sadd("foo", 1)
      @second = r.sadd("foo", 1)
    end

    assert_equal true, @first.value
    assert_equal false, @second.value
  end

  # Although we could support accessing the values in these futures,
  # it doesn't make a lot of sense.
  def test_assignment_of_results_inside_the_block_with_errors
    assert_raise(Redis::CommandError) do
      r.pipelined do
        r.doesnt_exist
        @first = r.sadd("foo", 1)
        @second = r.sadd("foo", 1)
      end
    end

    assert_raise(Redis::FutureNotReady) { @first.value }
    assert_raise(Redis::FutureNotReady) { @second.value }
  end

  def test_assignment_of_results_inside_a_nested_block
    r.pipelined do
      @first = r.sadd("foo", 1)

      r.pipelined do
        @second = r.sadd("foo", 1)
      end
    end

    assert_equal true, @first.value
    assert_equal false, @second.value
  end

  def test_futures_raise_when_confused_with_something_else
    r.pipelined do
      @result = r.sadd("foo", 1)
    end

    assert_raise(NoMethodError) { @result.to_s }
  end

  def test_futures_raise_when_trying_to_access_their_values_too_early
    r.pipelined do
      assert_raise(Redis::FutureNotReady) do
        r.sadd("foo", 1).value
      end
    end
  end

  def test_futures_can_be_identified
    r.pipelined do
      @result = r.sadd("foo", 1)
    end

    assert_equal true, @result.is_a?(Redis::Future)
    if defined?(::BasicObject)
      assert_equal true, @result.is_a?(::BasicObject)
    end
    assert_equal Redis::Future, @result.class
  end

  def test_returning_the_result_of_an_empty_pipeline
    result = r.pipelined do
    end

    assert_equal [], result
  end

  def test_nesting_pipeline_blocks
    r.pipelined do
      r.set("foo", "s1")
      r.pipelined do
        r.set("bar", "s2")
      end
    end

    assert_equal "s1", r.get("foo")
    assert_equal "s2", r.get("bar")
  end

  def test_info_in_a_pipeline_returns_hash
    result = r.pipelined do
      r.info
    end

    assert result.first.kind_of?(Hash)
  end

  def test_config_get_in_a_pipeline_returns_hash
    result = r.pipelined do
      r.config(:get, "*")
    end

    assert result.first.kind_of?(Hash)
  end

  def test_hgetall_in_a_pipeline_returns_hash
    r.hmset("hash", "field", "value")
    result = r.pipelined do
      r.hgetall("hash")
    end

    assert_equal result.first, { "field" => "value" }
  end

  def test_keys_in_a_pipeline
    r.set("key", "value")
    result = r.pipelined do
      r.keys("*")
    end

    assert_equal ["key"], result.first
  end

  def test_pipeline_yields_a_connection
    r.pipelined do |p|
      p.set("foo", "bar")
    end

    assert_equal "bar", r.get("foo")
  end

  def test_pipeline_select
    r.select 1
    r.set("db", "1")

    r.pipelined do |p|
      p.select 2
      p.set("db", "2")
    end

    r.select 1
    assert_equal "1", r.get("db")

    r.select 2
    assert_equal "2", r.get("db")
  end

  def test_pipeline_select_client_db
    r.select 1
    r.pipelined do |p2|
      p2.select 2
    end

    assert_equal 2, r.client.db
  end

  def test_nested_pipeline_select_client_db
    r.select 1
    r.pipelined do |p2|
      p2.select 2
      p2.pipelined do |p3|
        p3.select 3
      end
    end

    assert_equal 3, r.client.db
  end
end
