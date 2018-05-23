# frozen_string_literal: true

require "test_helper"

class BrowserTest < Minitest::Test
  test "sets user agent while instantianting object" do
    browser = Browser.new("Safari")
    assert_equal "Safari", browser.ua
  end

  test "don't fail with nil user agent" do
    browser = Browser.new(nil)
    refute browser.known?
  end

  %w[
    BlackBerry
    Chrome
    Edge
    Firefox
    MSIE
    Opera
    PhantomJS
    S40OviBrowser
    Safari
    UCBrowser
  ].each do |ua|
    test "don't fail when have no version info (#{ua})" do
      browser = Browser.new(ua)
      assert_equal "0", browser.version
      assert_equal "0.0", browser.full_version
    end
  end

  test "detects android" do
    browser = Browser.new(Browser["ANDROID"])

    assert_equal "Safari", browser.name
    assert browser.platform.android?
    assert browser.safari?
    assert browser.webkit?
    assert browser.modern?
    assert_equal "3.1.2", browser.full_version
    assert_equal "3", browser.version
  end

  test "detects android tablet" do
    browser = Browser.new(Browser["TABLOID"])

    assert_equal "Safari", browser.name
    assert browser.platform.android?
    assert browser.safari?
    assert browser.webkit?
    assert browser.modern?
    assert_equal "4.0", browser.full_version
    assert_equal "4", browser.version
  end

  test "detects surface tablet" do
    browser = Browser.new(Browser["SURFACE"])

    assert_equal "Internet Explorer", browser.name
    assert browser.device.surface?
    assert browser.ie?
    assert browser.modern?
    assert_equal "10.0", browser.full_version
    assert_equal "10", browser.version
  end

  test "detects quicktime" do
    browser = Browser.new(Browser["QUICKTIME"])

    assert_equal "QuickTime", browser.name
    assert browser.quicktime?
    assert_equal "7.6.8", browser.full_version
    assert_equal "7", browser.version
    assert browser.quicktime?(%w[>=7 <8])
  end

  test "detects core media" do
    browser = Browser.new(Browser["COREMEDIA"])

    assert_equal "Apple CoreMedia", browser.name
    assert browser.core_media?
    assert_equal "1.0.0.10", browser.full_version
    assert_equal "1", browser.version
    assert browser.core_media?(%w[>=1 <2])
  end

  test "detects phantom.js" do
    browser = Browser.new(Browser["PHANTOM_JS"])

    assert_equal "PhantomJS", browser.name
    assert_equal :phantom_js, browser.id
    assert browser.phantom_js?
    assert browser.modern?
    assert_equal "1.9.0", browser.full_version
    assert_equal "1", browser.version
    assert browser.phantom_js?(%w[>=1 <2])
  end

  test "returns a zero version" do
    browser = Browser.new("Bot")
    assert_equal "0.0", browser.full_version
    assert_equal "0", browser.version
  end

  test "detects unknown id" do
    browser = Browser.new("Unknown")
    assert_equal :generic, browser.id
  end

  test "detects unknown name" do
    browser = Browser.new("Unknown")
    assert_equal "Generic Browser", browser.name
  end

  test "returns empty language set for missing accept language" do
    browser = Browser.new("")
    assert_equal [], browser.accept_language
  end

  test "sets accept language while instantiating object" do
    browser = Browser.new("", accept_language: "pt-br")

    assert_kind_of Array, browser.accept_language
    assert_equal ["pt-BR"], browser.accept_language.map(&:full)
  end

  test "returns all known languages" do
    accept_language = "en-us,en;q=0.8,pt-br;q=0.5,pt;q=0.3"
    browser = Browser.new("", accept_language: accept_language)
    languages = browser.accept_language.map(&:full)

    assert_equal ["en-US", "en", "pt-BR", "pt"], languages
  end

  test "removes duplicate items" do
    browser = Browser.new(Browser["SAFARI"])
    assert_equal ["safari"], (browser.meta.select {|item| item == "safari" })
  end

  test "detects meta aliased as to_a" do
    browser = Browser.new(Browser["SAFARI"])
    assert_equal browser.meta, browser.to_a
  end

  test "knows a supported browser" do
    browser = Browser.new("Chrome")
    assert browser.known?
  end

  test "does not know an unsupported browser" do
    browser = Browser.new("Fancy new browser")
    refute browser.known?
  end
end
