require "minitest/autorun"
require "fog/json"

class TestJSONSanitizing < Minitest::Test
  def setup
    @time = Time.utc(2014, 02, 14, 12, 34, 56)
  end

  def test_sanitize_with_array
    @data = [@time]
    @expected = ["2014-02-14T12:34:56Z"]
    assert_equal @expected, Fog::JSON.sanitize(@data)
  end

  def test_sanitize_with_hash
    @data = { "key" => @time }
    @expected = { "key" => "2014-02-14T12:34:56Z" }
    assert_equal @expected, Fog::JSON.sanitize(@data)
  end

  def test_sanitize_with_time
    @data = @time
    @expected = "2014-02-14T12:34:56Z"
    assert_equal @expected, Fog::JSON.sanitize(@data)
  end

  def test_sanitize_with_string
    @data = "fog"
    @expected = "fog"
    assert_equal @expected, Fog::JSON.sanitize(@data)
  end
end
