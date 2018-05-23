# frozen_string_literal: true

require "test_helper"

class FirefoxTest < Minitest::Test
  test "detects firefox" do
    browser = Browser.new(Browser["FIREFOX"])

    assert_equal "Firefox", browser.name
    assert browser.firefox?
    refute browser.modern?
    assert_equal "3.8", browser.full_version
    assert_equal "3", browser.version
  end

  test "detects firefox for iOS" do
    browser = Browser.new(Browser["FIREFOX_IOS"])

    assert_equal "Firefox", browser.name
    assert browser.firefox?
    assert browser.platform.ios?
    assert_equal "1.2", browser.full_version
    assert_equal "1", browser.version
  end

  test "detects modern firefox" do
    browser = Browser.new(Browser["FIREFOX_MODERN"])

    assert_equal :firefox, browser.id
    assert_equal "Firefox", browser.name
    assert browser.firefox?
    assert browser.modern?
    assert_equal "17.0", browser.full_version
    assert_equal "17", browser.version
  end

  test "detects firefox android tablet" do
    browser = Browser.new(Browser["FIREFOX_TABLET"])

    assert_equal :firefox, browser.id
    assert_equal "Firefox", browser.name
    assert browser.firefox?
    assert browser.modern?
    assert browser.platform.android?
    assert_equal "14.0", browser.full_version
    assert_equal "14", browser.version
  end

  test "detects version by range" do
    browser = Browser.new(Browser["FIREFOX"])
    assert browser.firefox?(%w[>=3 <4])
  end
end
