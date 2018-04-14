# frozen_string_literal: true

require "test_helper"

class ElectronTest < Minitest::Test
  test "detect electron" do
    browser = Browser.new(Browser["ELECTRON"])

    assert_equal "Electron", browser.name
    assert browser.electron?
    assert_equal :electron, browser.id
    assert_equal "1.4.12", browser.full_version
  end
end
