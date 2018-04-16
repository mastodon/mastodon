# frozen_string_literal: true

require "test_helper"

class WindowsTest < Minitest::Test
  test "detects windows x64" do
    browser = Browser.new(Browser["IE10_X64_WINX64"])
    assert browser.platform.windows_x64?
    refute browser.platform.windows_wow64?
    assert browser.platform.windows_x64_inclusive?
    assert_equal browser.platform.version, "6.2"
  end

  test "detects windows wow64" do
    browser = Browser.new(Browser["WINDOWS_WOW64"])
    refute browser.platform.windows_x64?
    assert browser.platform.windows_wow64?
    assert browser.platform.windows_x64_inclusive?
    assert_equal browser.platform.version, "6.3"
  end

  test "detects windows_2000" do
    browser = Browser.new(Browser["WINDOWS_2000"])

    assert browser.platform.windows?
    assert_equal browser.platform.version, "5.0"
    assert browser.platform.windows?(["=5.0"])
  end

  test "detects windows_2000_sp1" do
    browser = Browser.new(Browser["WINDOWS_2000_SP1"])

    assert browser.platform.windows?
    assert_equal browser.platform.version, "5.01"
    assert browser.platform.windows?(["=5.01"])
  end

  test "detects windows_xp" do
    browser = Browser.new(Browser["WINDOWS_XP"])

    assert browser.platform.windows?
    assert browser.platform.windows_xp?
    assert_equal browser.platform.version, "5.1"
    assert browser.platform.windows?(["=5.1"])
  end

  test "detects windows_xp (64-bit)" do
    browser = Browser.new(Browser["WINDOWS_XP_64"])

    assert browser.platform.windows?
    assert browser.platform.windows_xp?
    assert browser.platform.windows_x64?
    assert_equal browser.platform.version, "5.2"
    assert browser.platform.windows?(["=5.2"])
  end

  test "detects windows_vista" do
    browser = Browser.new(Browser["WINDOWS_VISTA"])

    assert browser.platform.windows?
    assert browser.platform.windows_vista?
    assert_equal browser.platform.version, "6.0"
    assert browser.platform.windows?(["=6.0"])
  end

  test "detects windows7" do
    browser = Browser.new(Browser["WINDOWS7"])

    assert browser.platform.windows?
    assert browser.platform.windows7?
    assert_equal browser.platform.version, "6.1"
    assert browser.platform.windows?(["=6.1"])
  end

  test "detects windows8" do
    browser = Browser.new(Browser["WINDOWS8"])

    assert browser.platform.windows?
    assert browser.platform.windows8?
    refute browser.platform.windows8_1?
    assert_equal browser.platform.version, "6.2"
    assert browser.platform.windows?(["=6.2"])
  end

  test "detects windows8.1" do
    browser = Browser.new(Browser["WINDOWS81"])

    assert browser.platform.windows?
    assert browser.platform.windows8?
    assert browser.platform.windows8_1?
    assert_equal browser.platform.version, "6.3"
    assert browser.platform.windows?(["=6.3"])
  end

  test "detects windows10" do
    browser = Browser.new(Browser["WINDOWS10"])

    assert browser.platform.windows?
    assert browser.platform.windows10?
    assert_equal browser.platform.version, "10.0"
    assert browser.platform.windows?(["=10.0"])
  end

  test "returns name" do
    browser = Browser.new(Browser["WINDOWS8"])
    assert_equal "Windows", browser.platform.name
  end
end
