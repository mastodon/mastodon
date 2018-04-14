# frozen_string_literal: true

require "test_helper"

class AndroidAppTest < Minitest::Test
  let(:browser) { Browser.new(Browser["ANDROID_WEBVIEW"]) }

  test "detect as android" do
    assert browser.platform.android?
  end

  test "detect as webview" do
    assert browser.platform.android_webview?
  end

  test "non-webviews do not detect as webview" do
    %w[
      ANDROID_CUPCAKE
      ANDROID_DONUT
      ANDROID_ECLAIR_21
      ANDROID_FROYO
      ANDROID_GINGERBREAD
      ANDROID_HONEYCOMB_30
      ANDROID_ICECREAM
      ANDROID_JELLYBEAN_41
      ANDROID_JELLYBEAN_42
      ANDROID_JELLYBEAN_43
      ANDROID_KITKAT
      ANDROID_LOLLIPOP_50
      ANDROID_LOLLIPOP_51
      ANDROID_TV
      ANDROID_NEXUS_PLAYER
      FIREFOX_ANDROID
    ].each do |android_type|
      refute Browser.new(Browser[android_type]).platform.android_webview?
    end
  end
end
