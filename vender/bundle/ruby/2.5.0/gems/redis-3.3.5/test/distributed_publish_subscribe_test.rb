# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestDistributedPublishSubscribe < Test::Unit::TestCase

  include Helper::Distributed

  def test_subscribe_and_unsubscribe
    assert_raise Redis::Distributed::CannotDistribute do
      r.subscribe("foo", "bar") { }
    end

    assert_raise Redis::Distributed::CannotDistribute do
      r.subscribe("{qux}foo", "bar") { }
    end
  end

  def test_subscribe_and_unsubscribe_with_tags
    @subscribed = false
    @unsubscribed = false

    wire = Wire.new do
      r.subscribe("foo") do |on|
        on.subscribe do |channel, total|
          @subscribed = true
          @t1 = total
        end

        on.message do |channel, message|
          if message == "s1"
            r.unsubscribe
            @message = message
          end
        end

        on.unsubscribe do |channel, total|
          @unsubscribed = true
          @t2 = total
        end
      end
    end

    # Wait until the subscription is active before publishing
    Wire.pass while !@subscribed

    Redis::Distributed.new(NODES).publish("foo", "s1")

    wire.join

    assert @subscribed
    assert_equal 1, @t1
    assert @unsubscribed
    assert_equal 0, @t2
    assert_equal "s1", @message
  end

  def test_subscribe_within_subscribe
    @channels = []

    wire = Wire.new do
      r.subscribe("foo") do |on|
        on.subscribe do |channel, total|
          @channels << channel

          r.subscribe("bar") if channel == "foo"
          r.unsubscribe if channel == "bar"
        end
      end
    end

    wire.join

    assert_equal ["foo", "bar"], @channels
  end

  def test_other_commands_within_a_subscribe
    assert_raise Redis::CommandError do
      r.subscribe("foo") do |on|
        on.subscribe do |channel, total|
          r.set("bar", "s2")
        end
      end
    end
  end

  def test_subscribe_without_a_block
    assert_raise LocalJumpError do
      r.subscribe("foo")
    end
  end
end
