# frozen_string_literal: true

require "test_helper"

class BotsTest < Minitest::Test
  Browser.bot_user_agents.each do |key, ua|
    test "detect #{key} as bot" do
      browser = Browser.new(ua)
      assert browser.bot?
    end
  end

  test "don't detect as bot" do
    browser = Browser.new(Browser["CHROME"])
    refute browser.bot?
  end

  test "doesn't consider empty UA as bot" do
    browser = Browser.new("")
    refute browser.bot?
  end

  test "allows setting empty string as bots" do
    Browser::Bot.detect_empty_ua!
    browser = Browser.new("")

    assert browser.bot?
  end

  test "allows setting nil as user agent for bots" do
    browser = Browser.new(nil)
    refute browser.bot?

    Browser::Bot.detect_empty_ua!
    browser = Browser.new(nil)
    assert browser.bot?
  end

  test "doesn't detect mozilla as a bot when considering empty UA" do
    Browser::Bot.detect_empty_ua!
    browser = Browser.new("Mozilla")

    refute browser.bot?
  end

  test "returns bot name" do
    browser = Browser.new(Browser["GOOGLE_BOT"])
    assert_equal "Google Bot", browser.bot.name

    browser = Browser.new(Browser["FACEBOOK_BOT"])
    assert_equal "Facebook Bot", browser.bot.name
  end

  test "returns bot name (empty string ua detection enabled)" do
    Browser::Bot.detect_empty_ua!
    browser = Browser.new("")

    assert_equal browser.bot.name, "Generic Bot"
  end

  test "returns nil for non-bots" do
    browser = Browser.new(Browser["CHROME"])
    assert_nil browser.bot.name
  end

  Browser.search_engine_user_agents.each do |key, ua|
    test "detects #{key} as search engine" do
      browser = Browser.new(ua)
      assert browser.bot.search_engine?
    end
  end

  test "detects Daumoa" do
    browser = Browser.new(Browser["DAUMOA"])

    assert_equal :ie, browser.id
    assert_equal "Internet Explorer", browser.name
    assert_equal "0.0", browser.msie_full_version
    assert_equal "0", browser.msie_version
    assert_equal "0.0", browser.full_version
    assert_equal "0", browser.version
    assert browser.ie?
    assert browser.bot?
    refute browser.platform.windows10?
    refute browser.platform.windows_phone?
    refute browser.edge?
    refute browser.modern?
    refute browser.device.mobile?
    refute browser.webkit?
    refute browser.chrome?
    refute browser.safari?
  end

  test "custom android user agent (#144)" do
    browser = Browser.new(Browser["CUSTOM_APP"])

    assert browser.platform.android?
    refute browser.bot?
  end

  test "extends list in runtime" do
    browser = Browser.new("Faraday/0.9.2")
    refute browser.bot?

    Browser::Bot.bots["faraday"] = "Faraday"
    assert browser.bot?

    Browser::Bot.bots.delete("faraday")
  end
end
