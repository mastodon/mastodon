# frozen_string_literal: true

require "test_helper"
require "browser/aliases"

class AliasesTest < Minitest::Test
  class BrowserMock
    include Browser::Aliases

    def platform
      @platform ||= Object.new
    end

    def device
      @device ||= Object.new
    end
  end

  Browser::Aliases::PLATFORM_ALIASES.each do |method_name|
    test "adds #{method_name.inspect} as a platform alias" do
      browser = BrowserMock.new

      browser.platform.define_singleton_method(method_name) do
        :called
      end

      assert_equal :called, browser.public_send(method_name)
    end
  end

  Browser::Aliases::DEVICE_ALIASES.each do |method_name|
    test "adds #{method_name.inspect} as a device alias" do
      browser = BrowserMock.new

      browser.device.define_singleton_method(method_name) do
        :called
      end

      assert_equal :called, browser.public_send(method_name)
    end
  end
end
