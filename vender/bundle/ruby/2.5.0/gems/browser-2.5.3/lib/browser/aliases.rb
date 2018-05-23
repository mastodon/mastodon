# frozen_string_literal: true

require "browser"
require "forwardable"

module Browser
  module Aliases
    PLATFORM_ALIASES = %w[
      adobe_air? android? blackberry? chrome_os? firefox_os? ios? ios_app?
      ios_webview? linux? mac? windows10? windows7? windows8? windows8_1?
      windows? windows_mobile? windows_phone? windows_rt?
      windows_touchscreen_desktop? windows_vista? windows_wow64? windows_x64?
      windows_x64_inclusive? windows_xp?
    ].freeze

    DEVICE_ALIASES = %w[
      blackberry_playbook? console? ipad? iphone? ipod_touch? kindle?
      kindle_fire? mobile? nintendo? nintendo_wii? nintendo_wiiu? playbook?
      playstation3? playstation4? playstation? playstation_vita? ps3? ps4? psp?
      psp_vita? silk? surface? tablet? tv? vita? wii? wiiu? xbox? xbox_360?
      xbox_one?
    ].freeze

    def self.included(target)
      target.class_eval do
        extend Forwardable
        def_delegators :platform, *PLATFORM_ALIASES
        def_delegators :device, *DEVICE_ALIASES
      end
    end
  end
end
