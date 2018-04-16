# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestForkSafety < Test::Unit::TestCase

  include Helper::Client
  include Helper::Skipable

  driver(:ruby, :hiredis) do
    def test_fork_safety
      redis = Redis.new(OPTIONS)
      redis.set "foo", 1

      child_pid = fork do
        begin
          # InheritedError triggers a reconnect,
          # so we need to disable reconnects to force
          # the exception bubble up
          redis.without_reconnect do
            redis.set "foo", 2
          end
        rescue Redis::InheritedError
          exit 127
        end
      end

      _, status = Process.wait2(child_pid)

      assert_equal 127, status.exitstatus
      assert_equal "1", redis.get("foo")

    rescue NotImplementedError => error
      raise unless error.message =~ /fork is not available/
      return skip(error.message)
    end

    def test_fork_safety_with_enabled_inherited_socket
      redis = Redis.new(OPTIONS.merge(:inherit_socket => true))
      redis.set "foo", 1

      child_pid = fork do
        begin
          # InheritedError triggers a reconnect,
          # so we need to disable reconnects to force
          # the exception bubble up
          redis.without_reconnect do
            redis.set "foo", 2
          end
        rescue Redis::InheritedError
          exit 127
        end
      end

      _, status = Process.wait2(child_pid)

      assert_equal 0, status.exitstatus
      assert_equal "2", redis.get("foo")

    rescue NotImplementedError => error
      raise unless error.message =~ /fork is not available/
      return skip(error.message)
    end
  end
end
