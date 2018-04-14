# frozen_string_literal: true

require "test_helper"

class OperaTest < Minitest::Test
  test "detects opera" do
    browser = Browser.new(Browser["OPERA"])

    assert_equal "Opera", browser.name
    assert browser.opera?
    refute browser.modern?
    assert_equal "11.64", browser.full_version
    assert_equal "11", browser.version
  end

  test "detects opera next" do
    browser = Browser.new(Browser["OPERA_NEXT"])

    assert_equal "Opera", browser.name
    assert_equal :opera, browser.id
    assert browser.opera?
    assert browser.webkit?
    assert browser.modern?
    refute browser.chrome?
    assert_equal "15.0.1147.44", browser.full_version
    assert_equal "15", browser.version
  end

  test "detects opera mini" do
    browser = Browser.new(Browser["OPERA_MINI"])
    assert browser.opera_mini?
  end

  test "detects opera mini version by range" do
    browser = Browser.new(Browser["OPERA_MINI"])
    assert browser.opera_mini?(%w[>=11 <12])
  end

  test "detects opera mobi" do
    browser = Browser.new(Browser["OPERA_MOBI"])
    assert browser.opera?
  end

  test "detects opera running in Android" do
    browser = Browser.new(Browser["OPERA_ANDROID"])
    assert browser.platform.android?
  end

  test "detects version by range" do
    browser = Browser.new(Browser["OPERA"])
    assert browser.opera?(%w[>=11 <12])
  end
end
