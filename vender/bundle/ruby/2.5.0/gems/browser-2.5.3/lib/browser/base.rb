# frozen_string_literal: true

module Browser
  class Base
    include DetectVersion

    attr_reader :ua

    # Return an array with all preferred languages that this browser accepts.
    attr_reader :accept_language

    def initialize(ua, accept_language: nil)
      @ua = ua
      @accept_language = AcceptLanguage.parse(accept_language)
    end

    # Return a meta info about this browser.
    def meta
      Meta.get(self)
    end

    alias_method :to_a, :meta

    # Return meta representation as string.
    def to_s
      meta.to_a.join(" ")
    end

    def version
      full_version.split(".").first
    end

    # Return the platform.
    def platform
      @platform ||= Platform.new(ua)
    end

    # Return the bot info.
    def bot
      @bot ||= Bot.new(ua)
    end

    # Detect if current user agent is from a bot.
    def bot?
      bot.bot?
    end

    # Return the device info.
    def device
      @device ||= Device.new(ua)
    end

    # Return true if browser is modern (Webkit, Firefox 17+, IE9+, Opera 12+).
    def modern?
      Browser.modern_rules.any? {|rule| rule === self } # rubocop:disable Metrics/LineLength, Style/CaseEquality
    end

    # Detect if browser is Microsoft Internet Explorer.
    def ie?(expected_version = nil)
      InternetExplorer.new(ua).match? &&
        detect_version?(full_version, expected_version)
    end

    # Detect if browser is Microsoft Edge.
    def edge?(expected_version = nil)
      Edge.new(ua).match? && detect_version?(full_version, expected_version)
    end

    def compatibility_view?
      false
    end

    def msie_full_version
      "0.0"
    end

    def msie_version
      "0"
    end

    # Detect if browser if Facebook.
    def facebook?(expected_version = nil)
      Facebook.new(ua).match? &&
        detect_version?(full_version, expected_version)
    end

    # Detect if browser is Otter.
    def otter?(expected_version = nil)
      Otter.new(ua).match? &&
        detect_version?(full_version, expected_version)
    end

    # Detect if browser is WebKit-based.
    def webkit?(expected_version = nil)
      ua =~ /AppleWebKit/i &&
        !edge? &&
        detect_version?(webkit_full_version, expected_version)
    end

    # Detect if browser is QuickTime
    def quicktime?(expected_version = nil)
      ua =~ /QuickTime/i && detect_version?(full_version, expected_version)
    end

    # Detect if browser is Apple CoreMedia.
    def core_media?(expected_version = nil)
      ua =~ /CoreMedia/ && detect_version?(full_version, expected_version)
    end

    # Detect if browser is PhantomJS
    def phantom_js?(expected_version = nil)
      PhantomJS.new(ua).match? &&
        detect_version?(full_version, expected_version)
    end

    # Detect if browser is Safari.
    def safari?(expected_version = nil)
      Safari.new(ua).match? && detect_version?(version, expected_version)
    end

    def safari_webapp_mode?
      (device.ipad? || device.iphone?) && ua =~ /AppleWebKit/
    end

    # Detect if browser is Firefox.
    def firefox?(expected_version = nil)
      Firefox.new(ua).match? && detect_version?(full_version, expected_version)
    end

    # Detect if browser is Chrome.
    def chrome?(expected_version = nil)
      Chrome.new(ua).match? && detect_version?(full_version, expected_version)
    end

    # Detect if browser is Opera.
    def opera?(expected_version = nil)
      Opera.new(ua).match? && detect_version?(full_version, expected_version)
    end

    # Detect if browser is Yandex.
    def yandex?(expected_version = nil)
      ua =~ /YaBrowser/ && detect_version?(full_version, expected_version)
    end

    # Detect if browser is UCBrowser.
    def uc_browser?(expected_version = nil)
      UCBrowser.new(ua).match? &&
        detect_version?(full_version, expected_version)
    end

    # Detect if browser is Nokia S40 Ovi Browser.
    def nokia?(expected_version = nil)
      Nokia.new(ua).match? && detect_version?(full_version, expected_version)
    end

    # Detect if browser is MicroMessenger.
    def micro_messenger?(expected_version = nil)
      MicroMessenger.new(ua).match? &&
        detect_version?(full_version, expected_version)
    end

    alias_method :wechat?, :micro_messenger?

    def weibo?(expected_version = nil)
      Weibo.new(ua).match? && detect_version?(full_version, expected_version)
    end

    def alipay?(expected_version = nil)
      Alipay.new(ua).match? && detect_version?(full_version, expected_version)
    end

    # Detect if browser is Opera Mini.
    def opera_mini?(expected_version = nil)
      ua =~ /Opera Mini/ && detect_version?(full_version, expected_version)
    end

    def webkit_full_version
      ua[%r[AppleWebKit/([\d.]+)], 1] || "0.0"
    end

    def known?
      id != :generic
    end

    # Detect if browser is a proxy browser.
    def proxy?
      nokia? || uc_browser? || opera_mini?
    end

    # Detect if the browser is Electron.
    def electron?(expected_version = nil)
      Electron.new(ua).match? && detect_version?(full_version, expected_version)
    end
  end
end
