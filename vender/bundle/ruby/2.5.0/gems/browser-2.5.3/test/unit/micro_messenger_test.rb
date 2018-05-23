# frozen_string_literal: true

require "test_helper"

class MicroMessengerTest < Minitest::Test
  test "detects micro messenger 6.3.15" do
    browser = Browser.new(Browser["MICRO_MESSENGER"])

    assert browser.micro_messenger?
    assert browser.wechat?
    assert_equal "6.3.15", browser.full_version
    assert_equal "MicroMessenger", browser.name
    assert_equal :micro_messenger, browser.id
  end

  test "detects version by range" do
    browser = Browser.new(Browser["MICRO_MESSENGER"])
    assert browser.wechat?(%w[>=6 <7])
  end
end
