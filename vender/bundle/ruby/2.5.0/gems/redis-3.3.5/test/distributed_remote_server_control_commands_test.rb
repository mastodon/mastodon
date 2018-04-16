# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestDistributedRemoteServerControlCommands < Test::Unit::TestCase

  include Helper::Distributed

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

    infos = r.info

    infos.each do |info|
      keys.each do |k|
        msg = "expected #info to include #{k}"
        assert info.keys.include?(k), msg
      end
    end
  end

  def test_info_commandstats
    target_version "2.5.7" do
      r.nodes.each { |n| n.config(:resetstat) }
      r.ping # Executed on every node

      r.info(:commandstats).each do |info|
        assert_equal "1", info["ping"]["calls"]
      end
    end
  end

  def test_monitor
    begin
      r.monitor
    rescue Exception => ex
    ensure
      assert ex.kind_of?(NotImplementedError)
    end
  end

  def test_echo
    assert_equal ["foo bar baz\n"], r.echo("foo bar baz\n")
  end

  def test_time
    target_version "2.5.4" do
      # Test that the difference between the time that Ruby reports and the time
      # that Redis reports is minimal (prevents the test from being racy).
      r.time.each do |rv|
        redis_usec = rv[0] * 1_000_000 + rv[1]
        ruby_usec = Integer(Time.now.to_f * 1_000_000)

        assert 500_000 > (ruby_usec - redis_usec).abs
      end
    end
  end
end
