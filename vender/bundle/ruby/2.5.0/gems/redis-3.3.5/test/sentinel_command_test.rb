# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class SentinelCommandsTest < Test::Unit::TestCase

  include Helper::Client

  def test_sentinel_command_master

    handler = lambda do |id|
      {
        :sentinel => lambda do |command, *args|
          ["name", "master1", "ip", "127.0.0.1"]
        end
      }
    end

    RedisMock.start(handler.call(:s1)) do |port|
      redis = Redis.new(:host => "127.0.0.1", :port => port)

      result = redis.sentinel('master', 'master1')
      assert_equal result, { "name" => "master1", "ip" => "127.0.0.1" }
    end
  end

  def test_sentinel_command_masters

    handler = lambda do |id|
      {
        :sentinel => lambda do |command, *args|
          [%w[name master1 ip 127.0.0.1 port 6381], %w[name master1 ip 127.0.0.1 port 6382]]
        end
      }
    end

    RedisMock.start(handler.call(:s1)) do |port|
      redis = Redis.new(:host => "127.0.0.1", :port => port)

      result = redis.sentinel('masters')
      assert_equal result[0], { "name" => "master1", "ip" => "127.0.0.1", "port" => "6381" }
      assert_equal result[1], { "name" => "master1", "ip" => "127.0.0.1", "port" => "6382" }
    end
  end

  def test_sentinel_command_get_master_by_name

    handler = lambda do |id|
      {
        :sentinel => lambda do |command, *args|
          ["127.0.0.1", "6381"]
        end
      }
    end

    RedisMock.start(handler.call(:s1)) do |port|
      redis = Redis.new(:host => "127.0.0.1", :port => port)

      result = redis.sentinel('get-master-addr-by-name', 'master1')
      assert_equal result, ["127.0.0.1", "6381"]
    end
  end

  def test_sentinel_command_ckquorum
    handler = lambda do |id|
      {
        :sentinel => lambda do |command, *args|
          "+OK 2 usable Sentinels. Quorum and failover authorization can be reached"
        end
      }
    end

    RedisMock.start(handler.call(:s1)) do |port|
      redis = Redis.new(:host => "127.0.0.1", :port => port)

      result = redis.sentinel('ckquorum', 'master1')
      assert_equal result, "OK 2 usable Sentinels. Quorum and failover authorization can be reached"
    end
  end
end
