# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestRemoteServerControlCommands < Test::Unit::TestCase

  include Helper::Client

  def test_info
    keys = [
     "redis_version",
     "uptime_in_seconds",
     "uptime_in_days",
     "connected_clients",
     "used_memory",
     "total_connections_received",
     "total_commands_processed",
    ]

    info = r.info

    keys.each do |k|
      msg = "expected #info to include #{k}"
      assert info.keys.include?(k), msg
    end
  end

  def test_info_commandstats
    target_version "2.5.7" do
      r.config(:resetstat)
      r.ping

      result = r.info(:commandstats)
      assert_equal "1", result["ping"]["calls"]
    end
  end

  def test_monitor_redis_lt_2_5_0
    return unless version < "2.5.0"

    log = []

    wire = Wire.new do
      Redis.new(OPTIONS).monitor do |line|
        log << line
        break if log.size == 3
      end
    end

    Wire.pass while log.empty? # Faster than sleep

    r.set "foo", "s1"

    wire.join

    assert log[-1][%q{(db 15) "set" "foo" "s1"}]
  end

  def test_monitor_redis_gte_2_5_0
    return unless version >= "2.5.0"

    log = []

    wire = Wire.new do
      Redis.new(OPTIONS).monitor do |line|
        log << line
        break if line =~ /set/
      end
    end

    Wire.pass while log.empty? # Faster than sleep

    r.set "foo", "s1"

    wire.join

    assert log[-1] =~ /\b15\b.* "set" "foo" "s1"/
  end

  def test_monitor_returns_value_for_break
    result = r.monitor do |line|
      break line
    end

    assert_equal "OK", result
  end

  def test_echo
    assert_equal "foo bar baz\n", r.echo("foo bar baz\n")
  end

  def test_debug
    r.set "foo", "s1"

    assert r.debug(:object, "foo").kind_of?(String)
  end

  def test_object
    r.lpush "list", "value"

    assert_equal 1, r.object(:refcount, "list")
    encoding = r.object(:encoding, "list")
    assert "ziplist" == encoding || "quicklist" == encoding, "Wrong encoding for list"
    assert r.object(:idletime, "list").kind_of?(Integer)
  end

  def test_sync
    redis_mock(:sync => lambda { "+OK" }) do |redis|
      assert_equal "OK", redis.sync
    end
  end

  def test_slowlog
    r.slowlog(:reset)
    result = r.slowlog(:len)
    assert_equal 0, result
  end
end
