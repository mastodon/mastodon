# frozen_string_literal: true

require "test_helper"

class IeTest < Minitest::Test
  test "detects ie6" do
    browser = Browser.new(Browser["IE6"])

    assert_equal "Internet Explorer", browser.name
    assert browser.ie?
    assert browser.ie?(6)
    refute browser.modern?
    assert_equal "6.0", browser.full_version
    assert_equal "6", browser.version
  end

  test "detects ie7" do
    browser = Browser.new(Browser["IE7"])

    assert_equal "Internet Explorer", browser.name
    assert browser.ie?
    assert browser.ie?(7)
    refute browser.modern?
    assert_equal "7.0", browser.full_version
    assert_equal "7", browser.version
  end

  test "detects ie8" do
    browser = Browser.new(Browser["IE8"])

    assert_equal "Internet Explorer", browser.name
    assert browser.ie?
    assert browser.ie?(8)
    refute browser.modern?
    refute browser.compatibility_view?
    assert_equal "8.0", browser.full_version
    assert_equal "8", browser.version
  end

  test "detects ie8 in compatibility view" do
    browser = Browser.new(Browser["IE8_COMPAT"])

    assert_equal "Internet Explorer", browser.name
    assert browser.ie?
    assert browser.ie?(8)
    refute browser.modern?
    assert browser.compatibility_view?
    assert_equal "8.0", browser.full_version
    assert_equal "8", browser.version
    assert_equal "7.0", browser.msie_full_version
    assert_equal "7", browser.msie_version
  end

  test "detects ie9" do
    browser = Browser.new(Browser["IE9"])

    assert_equal "Internet Explorer", browser.name
    assert browser.ie?
    assert browser.ie?(9)
    assert browser.modern?
    refute browser.compatibility_view?
    assert_equal "9.0", browser.full_version
    assert_equal "9", browser.version
  end

  test "detects ie9 in compatibility view" do
    browser = Browser.new(Browser["IE9_COMPAT"])

    assert_equal "Internet Explorer", browser.name
    assert browser.ie?
    assert browser.ie?(9)
    refute browser.modern?
    assert browser.compatibility_view?
    assert_equal "9.0", browser.full_version
    assert_equal "9", browser.version
    assert_equal "7.0", browser.msie_full_version
    assert_equal "7", browser.msie_version
  end

  test "detects ie10" do
    browser = Browser.new(Browser["IE10"])

    assert_equal "Internet Explorer", browser.name
    assert browser.ie?
    assert browser.ie?(10)
    assert browser.modern?
    refute browser.compatibility_view?
    assert_equal "10.0", browser.full_version
    assert_equal "10", browser.version
  end

  test "detects ie10 in compatibility view" do
    browser = Browser.new(Browser["IE10_COMPAT"])

    assert_equal "Internet Explorer", browser.name
    assert browser.ie?
    assert browser.ie?(10)
    refute browser.modern?
    assert browser.compatibility_view?
    assert_equal "10.0", browser.full_version
    assert_equal "10", browser.version
    assert_equal "7.0", browser.msie_full_version
    assert_equal "7", browser.msie_version
  end

  test "detects ie11" do
    browser = Browser.new(Browser["IE11"])

    assert_equal "Internet Explorer", browser.name
    assert browser.ie?
    assert browser.ie?(11)
    assert browser.modern?
    refute browser.compatibility_view?
    assert_equal "11.0", browser.full_version
    assert_equal "11", browser.version
  end

  test "detects ie11 in compatibility view" do
    browser = Browser.new(Browser["IE11_COMPAT"])

    assert_equal "Internet Explorer", browser.name
    assert browser.ie?
    assert browser.ie?(11)
    refute browser.modern?
    assert browser.compatibility_view?
    assert_equal "11.0", browser.full_version
    assert_equal "11", browser.version
    assert_equal "7.0", browser.msie_full_version
    assert_equal "7", browser.msie_version
  end

  test "detects Lumia 800" do
    browser = Browser.new(Browser["LUMIA800"])

    assert_equal "Internet Explorer", browser.name
    assert browser.ie?
    assert browser.ie?(9)
    assert_equal "9.0", browser.full_version
    assert_equal "9", browser.version
  end

  test "detects ie11 touch desktop pc" do
    browser = Browser.new(Browser["IE11_TOUCH_SCREEN"])

    assert_equal "Internet Explorer", browser.name
    assert browser.ie?
    assert browser.ie?(11)
    assert browser.modern?
    refute browser.compatibility_view?
    refute browser.platform.windows_rt?
    assert browser.platform.windows_touchscreen_desktop?
    assert browser.platform.windows8?
    assert_equal "11.0", browser.full_version
    assert_equal "11", browser.version
  end

  test "detects IE without Trident" do
    browser = Browser.new(Browser["IE_WITHOUT_TRIDENT"])

    assert_equal :ie, browser.id
    assert_equal "Internet Explorer", browser.name
    assert_equal "0.0", browser.msie_full_version
    assert_equal "0", browser.msie_version
    assert_equal "0.0", browser.full_version
    assert_equal "0", browser.version
    refute browser.platform.windows10?
    refute browser.platform.windows_phone?
    refute browser.edge?
    refute browser.modern?
    refute browser.device.mobile?
    refute browser.webkit?
    refute browser.chrome?
    refute browser.safari?
  end

  test "detects windows phone" do
    browser = Browser.new(Browser["WINDOWS_PHONE"])

    assert browser.ie?
    assert_equal "7", browser.version
    assert browser.platform.windows_phone?
    refute browser.platform.windows_mobile?
  end

  test "detects windows phone 8" do
    browser = Browser.new(Browser["WINDOWS_PHONE8"])

    assert browser.ie?
    assert_equal "10", browser.version
    assert browser.platform.windows_phone?
    refute browser.platform.windows_mobile?
  end

  test "detects windows phone 8.1" do
    browser = Browser.new(Browser["WINDOWS_PHONE_81"])

    assert browser.ie?
    assert_equal "Internet Explorer", browser.name
    assert_equal :ie, browser.id
    assert_equal "11", browser.version
    assert_equal "11.0", browser.full_version
    assert browser.platform.windows_phone?
    refute browser.platform.windows_mobile?
  end

  test "detects windows mobile (windows phone 8)" do
    browser = Browser.new(Browser["WINDOWS_PHONE8"])

    assert browser.ie?
    assert_equal "10", browser.version
    assert browser.platform.windows_phone?
    refute browser.platform.windows_mobile?
  end

  test "detects windows x64" do
    browser = Browser.new(Browser["IE10_X64_WINX64"])
    assert browser.platform.windows_x64?
    refute browser.platform.windows_wow64?
    assert browser.platform.windows_x64_inclusive?
  end

  test "detects windows wow64" do
    browser = Browser.new(Browser["WINDOWS_WOW64"])
    refute browser.platform.windows_x64?
    assert browser.platform.windows_wow64?
    assert browser.platform.windows_x64_inclusive?
  end

  test "detects windows platform" do
    browser = Browser.new("Windows")
    assert_equal :windows, browser.platform.id
    assert browser.platform.windows?
  end

  test "detects windows_xp" do
    browser = Browser.new(Browser["WINDOWS_XP"])

    assert browser.platform.windows?
    assert browser.platform.windows_xp?
  end

  test "detects windows_vista" do
    browser = Browser.new(Browser["WINDOWS_VISTA"])

    assert browser.platform.windows?
    assert browser.platform.windows_vista?
  end

  test "detects windows7" do
    browser = Browser.new(Browser["WINDOWS7"])

    assert browser.platform.windows?
    assert browser.platform.windows7?
  end

  test "detects windows8" do
    browser = Browser.new(Browser["WINDOWS8"])

    assert browser.platform.windows?
    assert browser.platform.windows8?
    refute browser.platform.windows8_1?
  end

  test "detects windows8.1" do
    browser = Browser.new(Browser["WINDOWS81"])

    assert browser.platform.windows?
    assert browser.platform.windows8?
    assert browser.platform.windows8_1?
  end

  test "returns string representation for ie6" do
    browser = Browser.new(Browser["IE6"])
    meta = browser.meta

    assert meta.include?("ie")
    assert meta.include?("ie6")
    assert meta.include?("oldie")
    assert meta.include?("lt-ie8")
    assert meta.include?("lt-ie9")
    assert meta.include?("windows")
  end

  test "returns string representation for ie7" do
    browser = Browser.new(Browser["IE7"])
    meta = browser.meta

    assert meta.include?("ie")
    assert meta.include?("ie7")
    assert meta.include?("oldie")
    assert meta.include?("lt-ie8")
    assert meta.include?("lt-ie9")
    assert meta.include?("windows")
  end

  test "returns string representation for ie8" do
    browser = Browser.new(Browser["IE8"])
    meta = browser.meta

    assert meta.include?("ie")
    assert meta.include?("ie8")
    assert meta.include?("lt-ie9")
    assert meta.include?("windows")
  end

  test "don't detect as two different versions" do
    browser = Browser.new(Browser["IE8"])
    assert browser.ie?(8)
    refute browser.ie?(7)
  end

  test "more complex versioning check" do
    browser = Browser.new(Browser["IE8"])
    assert browser.ie?(["> 7", "< 9"])
  end
end
