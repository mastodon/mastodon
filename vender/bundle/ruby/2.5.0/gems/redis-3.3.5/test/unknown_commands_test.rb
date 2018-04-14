# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestUnknownCommands < Test::Unit::TestCase

  include Helper::Client

  def test_should_try_to_work
    assert_raise Redis::CommandError do
      r.not_yet_implemented_command
    end
  end
end
