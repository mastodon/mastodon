# frozen_string_literal: true

require "test_helper"

class IosAppTest < Minitest::Test
  let(:browser) { Browser.new(Browser["IOS_WEBVIEW"]) }

  test "detect as ios" do
    assert browser.platform.ios?
  end

  test "don't detect as safari" do
    refute browser.safari?
  end

  test "detect as webview" do
    assert browser.platform.ios_webview?
  end
end
