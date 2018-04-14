# frozen_string_literal: true

require "set"
require "yaml"
require "pathname"

require "browser/version"
require "browser/detect_version"
require "browser/accept_language"
require "browser/base"
require "browser/safari"
require "browser/chrome"
require "browser/internet_explorer"
require "browser/firefox"
require "browser/edge"
require "browser/opera"
require "browser/blackberry"
require "browser/generic"
require "browser/phantom_js"
require "browser/uc_browser"
require "browser/nokia"
require "browser/micro_messenger"
require "browser/weibo"
require "browser/qq"
require "browser/alipay"
require "browser/electron"
require "browser/facebook"
require "browser/otter"

require "browser/bot"
require "browser/middleware"

require "browser/platform"
require "browser/device"
require "browser/meta"

module Browser
  EMPTY_STRING = "".freeze

  def self.root
    @root ||= Pathname.new(File.expand_path("../../..", __FILE__))
  end

  # Hold the list of browser matchers.
  # Order is important.
  def self.matchers
    @matchers ||= [
      Nokia,
      UCBrowser,
      PhantomJS,
      BlackBerry,
      Opera,
      Edge,
      InternetExplorer,
      Firefox,
      Otter,
      Facebook,             # must be placed before Chrome and Safari
      Weibo,                # must be placed before Chrome and Safari
      QQ,                   # must be placed before Chrome and Safari
      Alipay,               # must be placed before Chrome and Safari
      Electron,             # must be placed before Chrome and Safari
      Chrome,
      Safari,
      MicroMessenger,
      Generic
    ]
  end

  # Define the rules which define a modern browser.
  # A rule must be a proc/lambda or any object that implements the method
  # === and accepts the browser object.
  #
  # To redefine all rules, clear the existing rules before adding your own.
  #
  #   # Only Chrome Canary is considered modern.
  #   Browser.modern_rules.clear
  #   Browser.modern_rules << -> b { b.chrome? && b.version >= "37" }
  #
  def self.modern_rules
    @modern_rules ||= []
  end

  modern_rules.tap do |rules|
    rules << ->(b) { b.webkit? }
    rules << ->(b) { b.firefox? && b.version.to_i >= 17 }
    rules << ->(b) { b.ie? && b.version.to_i >= 9 && !b.compatibility_view? }
    rules << ->(b) { b.edge? && !b.compatibility_view? }
    rules << ->(b) { b.opera? && b.version.to_i >= 12 }
    rules << ->(b) { b.firefox? && b.device.tablet? && b.platform.android? && b.version.to_i >= 14 } # rubocop:disable Metrics/LineLength
  end

  def self.new(user_agent, **kwargs)
    matchers
      .map {|klass| klass.new(user_agent || EMPTY_STRING, **kwargs) }
      .find(&:match?)
  end
end
