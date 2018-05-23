# frozen_string_literal: true

require "test_helper"

class WindowPhoneTest < Minitest::Test
  test "detects windows phone" do
    browser = Browser.new(Browser["WINDOWS_PHONE"])

    assert browser.ie?
    assert_equal "7", browser.version
    assert browser.platform.windows_phone?
    refute browser.platform.windows_mobile?
  end

  test "detects windows phone 8" do
    browser = Browser.new(Browser["WINDOWS_PHONE8"])

    assert browser.ie?
    assert_equal "10", browser.version
    assert browser.platform.windows_phone?
    refute browser.platform.windows_mobile?
  end

  test "detects windows phone 8.1" do
    browser = Browser.new(Browser["WINDOWS_PHONE_81"])

    assert browser.ie?
    assert_equal "Internet Explorer", browser.name
    assert_equal :ie, browser.id
    assert_equal "11", browser.version
    assert_equal "11.0", browser.full_version
    assert browser.platform.windows_phone?
    refute browser.platform.windows_mobile?
  end
end
