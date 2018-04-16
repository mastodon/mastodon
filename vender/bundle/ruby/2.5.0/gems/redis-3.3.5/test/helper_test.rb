# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestHelper < Test::Unit::TestCase

  include Helper

  def test_version_comparison
    v = Version.new("2.0.1")

    assert v > "1"
    assert v > "2"
    assert v < "3"
    assert v < "10"

    assert v < "2.1"
    assert v < "2.0.2"
    assert v < "2.0.1.1"
    assert v < "2.0.10"

    assert v == "2.0.1"
  end
end
