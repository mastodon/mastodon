# frozen_string_literal: true

require "test_helper"

class AlipayTest < Minitest::Test
  test "detects alipay iOS" do
    browser = Browser.new(Browser["ALIPAY_IOS"])

    assert_equal :alipay, browser.id
    assert browser.alipay?
    assert_equal "Alipay", browser.name
    assert_equal "2.3.4", browser.full_version
  end

  test "detects alipay Android" do
    browser = Browser.new(Browser["ALIPAY_ANDROID"])

    assert_equal :alipay, browser.id
    assert browser.alipay?
    assert_equal "Alipay", browser.name
    assert_equal "9.0.1.073001", browser.full_version
  end

  test "detects version by range" do
    browser = Browser.new(Browser["ALIPAY_IOS"])
    assert browser.alipay?(%w[>=2 <3])
  end
end
