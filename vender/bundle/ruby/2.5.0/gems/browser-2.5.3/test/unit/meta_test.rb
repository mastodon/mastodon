# frozen_string_literal: true

require "test_helper"

class MetaTest < Minitest::Test
  class CustomRule < Browser::Meta::Base
    def meta
      "custom" if browser.ua =~ /Custom/
    end
  end

  test "extend rules" do
    Browser::Meta.rules.unshift(CustomRule)

    browser = Browser.new("Custom")
    assert browser.meta.include?("custom")

    browser = Browser.new("Safari")
    refute browser.meta.include?("custom")

    Browser::Meta.rules.shift

    browser = Browser.new("Custom")
    refute browser.meta.include?("custom")
  end

  test "sets meta" do
    browser = Browser.new(Browser["CHROME"])
    assert_kind_of Array, browser.meta
  end

  test "returns string representation" do
    browser = Browser.new(Browser["CHROME"])
    meta = browser.to_s

    assert meta.include?("chrome")
    assert meta.include?("webkit")
    assert meta.include?("mac")
    assert meta.include?("modern")
  end

  test "returns string representation for mobile" do
    browser = Browser.new(Browser["BLACKBERRY"])
    meta = browser.to_s

    assert meta.include?("blackberry")
    assert meta.include?("mobile")
  end
end
