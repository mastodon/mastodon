# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestEncoding < Test::Unit::TestCase

  include Helper::Client

  def test_returns_properly_encoded_strings
    if defined?(Encoding)
      with_external_encoding("UTF-8") do
        r.set "foo", "שלום"

        assert_equal "Shalom שלום", "Shalom " + r.get("foo")
      end
    end
  end
end
