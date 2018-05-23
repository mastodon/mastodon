# frozen_string_literal: true

require "test_helper"

class AdobeAirTest < Minitest::Test
  test "detects adobe air" do
    browser = Browser.new(Browser["ADOBE_AIR"])

    assert browser.webkit?
    assert_equal "0", browser.version
    assert_equal "0.0", browser.full_version
    assert_equal "Generic Browser", browser.name
    assert_equal "Adobe AIR", browser.platform.name
    assert_equal "13.0", browser.platform.version
  end
end
