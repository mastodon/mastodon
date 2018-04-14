# frozen_string_literal: true

require "test_helper"

class ProxyTest < Minitest::Test
  %w[
    NOKIA
    OPERA_MINI
    UC_BROWSER
  ].each do |name|
    ua = Browser[name]

    test "detect #{name} as proxy" do
      browser = Browser.new(ua)

      assert browser.proxy?
      assert browser.meta.include?("proxy")
    end
  end
end
