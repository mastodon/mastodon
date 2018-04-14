# frozen_string_literal: true

require "test_helper"

class ChromeTest < Minitest::Test
  test "detects chrome" do
    browser = Browser.new(Browser["CHROME"])

    assert_equal "Chrome", browser.name
    assert browser.chrome?
    refute browser.safari?
    assert browser.webkit?
    assert browser.modern?
    assert_equal "5.0.375.99", browser.full_version
    assert_equal "5", browser.version
  end

  test "detects mobile chrome" do
    browser = Browser.new(Browser["MOBILE_CHROME"])

    assert_equal "Chrome", browser.name
    assert browser.chrome?
    refute browser.safari?
    assert browser.webkit?
    assert browser.modern?
    assert_equal "19.0.1084.60", browser.full_version
    assert_equal "19", browser.version
  end

  test "detects samsung chrome" do
    browser = Browser.new(Browser["SAMSUNG_CHROME"])

    assert_equal "Chrome", browser.name
    assert browser.chrome?
    assert browser.platform.android?
    refute browser.safari?
    assert browser.webkit?
    assert browser.modern?
    assert_equal "28.0.1500.94", browser.full_version
    assert_equal "28", browser.version
  end

  test "detects chrome os" do
    browser = Browser.new(Browser["CHROME_OS"])
    assert browser.platform.chrome_os?
  end

  test "detects yandex browser" do
    browser = Browser.new(Browser["YANDEX_BROWSER"])

    assert browser.yandex?
    assert browser.chrome?
    refute browser.safari?
    assert browser.webkit?
    assert_equal "41.0.2272.118", browser.full_version
    assert_equal "41", browser.version
  end

  test "detects yandex version by range" do
    browser = Browser.new(Browser["YANDEX_BROWSER"])
    assert browser.yandex?(%w[>=41 <42])
  end

  test "detects chrome frame" do
    browser = Browser.new(Browser["IE9_CHROME_FRAME"])

    assert browser.chrome?
    refute browser.safari?
    assert browser.webkit?
    assert_equal "26.0.1410.43", browser.full_version
    assert_equal "26", browser.version
  end

  test "detects chrome not opera when android build number contains 'OPR'" do
    browser = Browser.new(Browser["ANDROID_OREO"])

    assert browser.chrome?
  end

  test "detects version by range" do
    browser = Browser.new(Browser["CHROME"])
    assert browser.chrome?(%w[>=5 <6])
  end
end
