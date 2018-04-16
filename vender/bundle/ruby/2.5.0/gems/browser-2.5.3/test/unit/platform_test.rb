# frozen_string_literal: true

require "test_helper"

class PlatformTest < Minitest::Test
  class CustomPlatform < Browser::Platform::Base
    def match?
      ua =~ /Custom/
    end

    def id
      :custom
    end
  end

  test "extend matchers" do
    Browser::Platform.matchers.unshift(CustomPlatform)
    platform = Browser::Platform.new("Custom")
    assert_equal :custom, platform.id

    Browser::Platform.matchers.shift
    platform = Browser::Platform.new("Custom")
    assert_equal :other, platform.id
  end

  test "implements to_s" do
    platform = Browser::Platform.new(Browser["IOS9"])
    assert_equal "ios", platform.to_s
  end

  test "implements ==" do
    platform = Browser::Platform.new(Browser["IOS9"])

    assert platform == :ios
    refute platform == :android
  end

  test "detect other" do
    platform = Browser::Platform.new("Other")

    assert_equal "Other", platform.name
    assert_equal :other, platform.id
    assert_equal "0", platform.version
    assert platform.other?
  end

  test "detect ios (iPhone)" do
    platform = Browser::Platform.new(Browser["IOS4"])

    assert_equal "iOS (iPhone)", platform.name
    assert_equal :ios, platform.id
    assert platform.ios?
    assert_equal "4", platform.version
  end

  test "detect ios (iPad)" do
    platform = Browser::Platform.new(Browser["IOS9"])

    assert_equal "iOS (iPad)", platform.name
    assert_equal :ios, platform.id
    assert platform.ios?
    assert_equal "9", platform.version
  end

  test "detect ios (iPod Touch)" do
    platform = Browser::Platform.new(Browser["IPOD"])

    assert_equal "iOS (iPod)", platform.name
    assert_equal :ios, platform.id
    assert platform.ios?
    assert_equal "0", platform.version
  end

  test "detect linux" do
    platform = Browser::Platform.new(Browser["FIREFOX"])

    assert_equal "Generic Linux", platform.name
    assert_equal :linux, platform.id
    assert platform.linux?
    assert_equal "0", platform.version
  end

  test "detect mac" do
    platform = Browser::Platform.new(Browser["SAFARI"])

    assert_equal "Macintosh", platform.name
    assert_equal :mac, platform.id
    assert platform.mac?
    assert_equal "10.6.4", platform.version
    assert platform.mac?(["=10.6.4"])
  end

  test "return stub version for Mac user agent without version" do
    platform = Browser::Platform.new("Macintosh")
    assert_equal "0", platform.version
  end

  test "detect firefox os" do
    platform = Browser::Platform.new(Browser["FIREFOX_OS"])

    assert_equal "Firefox OS", platform.name
    assert_equal :firefox_os, platform.id
    assert platform.firefox_os?
    assert_equal "0", platform.version
  end

  test "detect windows phone" do
    platform = Browser::Platform.new(Browser["MS_EDGE_MOBILE"])

    assert_equal "Windows Phone", platform.name
    assert_equal :windows_phone, platform.id
    assert platform.windows_phone?
    assert_equal "10.0", platform.version
  end

  test "detect windows mobile" do
    platform = Browser::Platform.new(Browser["WINDOWS_MOBILE"])

    assert_equal "Windows Mobile", platform.name
    assert_equal :windows_mobile, platform.id
    assert platform.windows_mobile?
    assert_equal "0", platform.version
  end

  test "detect blackberry 10" do
    platform = Browser::Platform.new(Browser["BLACKBERRY10"])

    assert_equal "BlackBerry", platform.name
    assert_equal :blackberry, platform.id
    assert platform.blackberry?
    assert_equal "10.0.9.1675", platform.version
  end

  test "detect blackberry 4" do
    platform = Browser::Platform.new(Browser["BLACKBERRY4"])

    assert_equal "BlackBerry", platform.name
    assert_equal :blackberry, platform.id
    assert platform.blackberry?
    assert_equal "4.2.1", platform.version
  end

  test "detect blackberry 4 (other)" do
    platform = Browser::Platform.new(Browser["BLACKBERRY"])

    assert_equal "BlackBerry", platform.name
    assert_equal :blackberry, platform.id
    assert platform.blackberry?
    assert_equal "4.1.0", platform.version
  end

  test "detect blackberry 5" do
    platform = Browser::Platform.new(Browser["BLACKBERRY5"])

    assert_equal "BlackBerry", platform.name
    assert_equal :blackberry, platform.id
    assert platform.blackberry?
    assert_equal "5.0.0.93", platform.version
  end

  test "detect blackberry 6" do
    platform = Browser::Platform.new(Browser["BLACKBERRY6"])

    assert_equal "BlackBerry", platform.name
    assert_equal :blackberry, platform.id
    assert platform.blackberry?
    assert_equal "6.0.0.141", platform.version
  end

  test "detect blackberry 7" do
    platform = Browser::Platform.new(Browser["BLACKBERRY7"])

    assert_equal "BlackBerry", platform.name
    assert_equal :blackberry, platform.id
    assert platform.blackberry?
    assert_equal "7.0.0.1", platform.version
  end

  test "detect android" do
    platform = Browser::Platform.new(Browser["ANDROID_CUPCAKE"])

    assert_equal "Android", platform.name
    assert_equal :android, platform.id
    assert platform.android?
    assert_equal "1.5", platform.version
  end

  test "detect chrome os" do
    platform = Browser::Platform.new(Browser["CHROME_OS"])

    assert_equal "Chrome OS", platform.name
    assert_equal :chrome_os, platform.id
    assert platform.chrome_os?
    assert platform.chrome_os?(%w[>=3701 <3702])
    assert_equal "3701.81.0", platform.version
  end

  test "detect adobe air" do
    platform = Browser::Platform.new(Browser["ADOBE_AIR"])

    assert platform.adobe_air?
    assert platform.adobe_air?(%w[>=13 <14])
  end
end
