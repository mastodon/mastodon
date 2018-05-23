# frozen_string_literal: true

require "test_helper"

class OtterBrowserTest < Minitest::Test
  test "detects Otter Browser" do
    browser = Browser.new(Browser["OTTER"])

    assert browser.otter?
    assert_equal "Otter", browser.name
    assert_equal :otter, browser.id
    assert_equal "0.9.91", browser.full_version
    assert_equal "0", browser.version
  end

  test "detects version by range" do
    browser = Browser.new(Browser["OTTER"])
    assert browser.otter?(%w[=0.9.91])
  end
end
