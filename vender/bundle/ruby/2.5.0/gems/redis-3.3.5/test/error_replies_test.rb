# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestErrorReplies < Test::Unit::TestCase

  include Helper::Client

  # Every test shouldn't disconnect from the server. Also, when error replies are
  # in play, the protocol should never get into an invalid state where there are
  # pending replies in the connection. Calling INFO after every test ensures that
  # the protocol is still in a valid state.
  def with_reconnection_check
    before = r.info["total_connections_received"]
    yield(r)
    after = r.info["total_connections_received"]
  ensure
    assert_equal before, after
  end

  def test_error_reply_for_single_command
    with_reconnection_check do
      begin
        r.unknown_command
      rescue => ex
      ensure
        assert ex.message =~ /unknown command/i
      end
    end
  end

  def test_raise_first_error_reply_in_pipeline
    with_reconnection_check do
      begin
        r.pipelined do
          r.set("foo", "s1")
          r.incr("foo") # not an integer
          r.lpush("foo", "value") # wrong kind of value
        end
      rescue => ex
      ensure
        assert ex.message =~ /not an integer/i
      end
    end
  end

  def test_recover_from_raise_in__call_loop
    with_reconnection_check do
      begin
        r.client.call_loop([:invalid_monitor]) do
          assert false # Should never be executed
        end
      rescue => ex
      ensure
        assert ex.message =~ /unknown command/i
      end
    end
  end
end
