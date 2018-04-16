require "minitest/autorun"
require "fog/json"

class TestJSONEncoding < Minitest::Test
  def test_encode_array
    @array = %W(one two three)
    @expected = %q{["one","two","three"]}
    assert_equal @expected, Fog::JSON.encode(@array)
  end

  def test_encode_hash
    @hash = {
      "key" => "value"
    }
    @expected = %q{{"key":"value"}}
    assert_equal @expected, Fog::JSON.encode(@hash)
  end

  def test_encode_with_bad_input
    skip if %w(1.8.7 2.0.0).include?(RUBY_VERSION)
    assert_raises(Fog::JSON::EncodeError) { Fog::JSON.encode("\x82\xAC\xEF") }
  end
end
