require "minitest/autorun"
require "fog/json"

class TestJSONDecoding < Minitest::Test
  def test_decode_array
    @json = %q{["one", "two", "three"]}
    @expected = %w(one two three)
    assert_equal @expected, Fog::JSON.decode(@json)
  end

  def test_decode_hash
    @json = %q{{"key":"value"}}
    @expected = { "key" => "value" }
    assert_equal @expected, Fog::JSON.decode(@json)
  end

  def test_decode_with_nil
    assert_raises(Fog::JSON::DecodeError) { Fog::JSON.decode(nil) }
  end
end
