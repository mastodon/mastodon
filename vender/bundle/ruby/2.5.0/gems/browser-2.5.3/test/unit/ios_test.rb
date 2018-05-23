# frozen_string_literal: true

require "test_helper"

class IosTest < Minitest::Test
  test "detects iphone" do
    browser = Browser.new(Browser["IPHONE"])

    assert_equal "Safari", browser.name
    assert browser.safari?
    assert browser.webkit?
    assert browser.modern?
    assert browser.platform.ios?
    refute browser.platform.mac?
    assert_equal "3.0", browser.full_version
    assert_equal "3", browser.version
  end

  test "detects safari" do
    browser = Browser.new(Browser["SAFARI"])

    assert_equal "Safari", browser.name
    assert browser.safari?
    assert browser.webkit?
    assert browser.modern?
    assert_equal "5.0.1", browser.full_version
    assert_equal "5", browser.version
  end

  test "detects safari in webapp mode" do
    browser = Browser.new(Browser["SAFARI_IPAD_WEBAPP_MODE"])
    refute browser.safari?
    assert browser.platform.ios_webview?

    browser = Browser.new(Browser["SAFARI_IPHONE_WEBAPP_MODE"])
    refute browser.safari?
    assert browser.platform.ios_webview?
  end

  test "detects ipod" do
    browser = Browser.new(Browser["IPOD"])

    assert_equal "Safari", browser.name
    assert browser.safari?
    assert browser.webkit?
    assert browser.platform.ios?
    refute browser.device.tablet?
    refute browser.platform.mac?
    assert_equal "3.0", browser.full_version
    assert_equal "3", browser.version
  end

  test "detects ipad" do
    browser = Browser.new(Browser["IPAD"])

    assert_equal "Safari", browser.name
    assert browser.safari?
    assert browser.webkit?
    assert browser.modern?
    assert browser.platform.ios?
    refute browser.platform.mac?
    assert_equal "4.0.4", browser.full_version
    assert_equal "4", browser.version
  end

  test "detects ios4" do
    browser = Browser.new(Browser["IOS4"])
    assert browser.platform.ios?
    assert browser.platform.ios?(4)
    refute browser.platform.mac?
  end

  test "detects ios5" do
    browser = Browser.new(Browser["IOS5"])
    assert browser.platform.ios?
    assert browser.platform.ios?(5)
    refute browser.platform.mac?
  end

  test "detects ios6" do
    browser = Browser.new(Browser["IOS6"])
    assert browser.platform.ios?
    assert browser.platform.ios?(6)
    refute browser.platform.mac?
  end

  test "detects ios7" do
    browser = Browser.new(Browser["IOS7"])
    assert browser.platform.ios?
    assert browser.platform.ios?(7)
    refute browser.platform.mac?
  end

  test "detects ios8" do
    browser = Browser.new(Browser["IOS8"])
    assert browser.platform.ios?
    assert browser.platform.ios?(8)
    refute browser.platform.mac?
  end

  test "detects ios9" do
    browser = Browser.new(Browser["IOS9"])
    assert browser.platform.ios?
    assert browser.platform.ios?(9)
    refute browser.platform.mac?
  end

  test "don't detect as two different versions" do
    browser = Browser.new(Browser["IOS8"])
    assert browser.platform.ios?(8)
    refute browser.platform.ios?(7)
  end

  test "returns string representation for iphone" do
    browser = Browser.new(Browser["IPHONE"])
    meta = browser.to_s

    assert meta.include?("webkit")
    assert meta.include?("ios")
    assert meta.include?("safari")
    assert meta.include?("safari3")
    assert meta.include?("modern")
    assert meta.include?("mobile")
    refute meta.include?("tablet")
  end

  test "returns string representation for ipad" do
    browser = Browser.new(Browser["IPAD"])
    meta = browser.to_s

    assert meta.include?("webkit")
    assert meta.include?("ios")
    assert meta.include?("safari")
    assert meta.include?("modern")
    assert meta.include?("tablet")
    refute meta.include?("mobile")
  end
end
