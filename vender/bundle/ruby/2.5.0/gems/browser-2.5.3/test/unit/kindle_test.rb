# frozen_string_literal: true

require "test_helper"

class KindleTest < Minitest::Test
  test "detects kindle monochrome" do
    browser = Browser.new(Browser["KINDLE"])
    assert browser.webkit?
  end

  test "detects kindle fire" do
    browser = Browser.new(Browser["KINDLE_FIRE"])
    assert browser.webkit?
  end

  test "detects kindle fire hd" do
    browser = Browser.new(Browser["KINDLE_FIRE_HD"])

    assert browser.webkit?
    assert browser.modern?
  end

  test "detects kindle fire hd mobile" do
    browser = Browser.new(Browser["KINDLE_FIRE_HD_MOBILE"])

    assert browser.webkit?
    assert browser.modern?
  end
end
