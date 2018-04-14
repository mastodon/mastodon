# frozen_string_literal: true

require "test_helper"

class FacebookTest < Minitest::Test
  test "detects facebook" do
    browser = Browser.new(Browser["FACEBOOK"])

    assert_equal "Facebook", browser.name
    assert browser.facebook?
    assert :facebook, browser.id
    assert_equal "135.0.0.45.90", browser.full_version
    assert_equal "135", browser.version
  end

  test "detects version by range" do
    browser = Browser.new(Browser["FACEBOOK"])
    assert browser.facebook?(%w[>=135])
  end
end
