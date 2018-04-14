# frozen_string_literal: true

require "test_helper"

class BlackberryTest < Minitest::Test
  test "detects blackberry" do
    browser = Browser.new(Browser["BLACKBERRY"])

    assert_equal "BlackBerry", browser.name
    refute browser.device.tablet?
    assert browser.device.mobile?
    refute browser.modern?
    assert_equal "4.1.0", browser.full_version
    assert_equal "4", browser.version
  end

  test "detects blackberry4" do
    browser = Browser.new(Browser["BLACKBERRY4"])

    assert_equal "BlackBerry", browser.name
    refute browser.modern?
    assert_equal "4.2.1", browser.full_version
    assert_equal "4", browser.version
  end

  test "detects blackberry5" do
    browser = Browser.new(Browser["BLACKBERRY5"])

    assert_equal "BlackBerry", browser.name
    refute browser.device.tablet?
    assert browser.device.mobile?
    refute browser.modern?
    assert_equal "5.0.0.93", browser.full_version
    assert_equal "5", browser.version
  end

  test "detects blackberry6" do
    browser = Browser.new(Browser["BLACKBERRY6"])

    assert_equal "BlackBerry", browser.name
    refute browser.device.tablet?
    assert browser.device.mobile?
    assert browser.modern?
    assert_equal "6.0.0.141", browser.full_version
    assert_equal "6", browser.version
  end

  test "detects blackberry7" do
    browser = Browser.new(Browser["BLACKBERRY7"])

    assert_equal "BlackBerry", browser.name
    refute browser.device.tablet?
    assert browser.device.mobile?
    assert browser.modern?
    assert_equal "7.0.0.1", browser.full_version
    assert_equal "7", browser.version
  end

  test "detects blackberry10" do
    browser = Browser.new(Browser["BLACKBERRY10"])

    assert_equal "BlackBerry", browser.name
    refute browser.device.tablet?
    assert browser.device.mobile?
    assert browser.modern?
    assert_equal "10.0.9.1675", browser.full_version
    assert_equal "10", browser.version
  end

  test "detects blackberry playbook tablet" do
    browser = Browser.new(Browser["PLAYBOOK"])

    refute browser.platform.android?
    assert browser.device.tablet?
    refute browser.device.mobile?

    assert_equal "7.2.1.0", browser.full_version
    assert_equal "7", browser.version
  end

  test "don't detect as two different versions" do
    browser = Browser.new(Browser["BLACKBERRY10"])
    assert browser.platform.blackberry?("~> 10.0")
    refute browser.platform.blackberry?("~> 7.0")
  end
end
