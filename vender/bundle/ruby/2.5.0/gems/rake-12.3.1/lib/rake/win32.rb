# frozen_string_literal: true
require "rbconfig"

module Rake
  # Win 32 interface methods for Rake. Windows specific functionality
  # will be placed here to collect that knowledge in one spot.
  module Win32 # :nodoc: all

    # Error indicating a problem in locating the home directory on a
    # Win32 system.
    class Win32HomeError < RuntimeError
    end

    class << self
      # True if running on a windows system.
      def windows?
        RbConfig::CONFIG["host_os"] =~ %r!(msdos|mswin|djgpp|mingw|[Ww]indows)!
      end

      # The standard directory containing system wide rake files on
      # Win 32 systems. Try the following environment variables (in
      # order):
      #
      # * HOME
      # * HOMEDRIVE + HOMEPATH
      # * APPDATA
      # * USERPROFILE
      #
      # If the above are not defined, the return nil.
      def win32_system_dir #:nodoc:
        win32_shared_path = ENV["HOME"]
        if win32_shared_path.nil? && ENV["HOMEDRIVE"] && ENV["HOMEPATH"]
          win32_shared_path = ENV["HOMEDRIVE"] + ENV["HOMEPATH"]
        end

        win32_shared_path ||= ENV["APPDATA"]
        win32_shared_path ||= ENV["USERPROFILE"]
        raise Win32HomeError,
          "Unable to determine home path environment variable." if
            win32_shared_path.nil? or win32_shared_path.empty?
        normalize(File.join(win32_shared_path, "Rake"))
      end

      # Normalize a win32 path so that the slashes are all forward slashes.
      def normalize(path)
        path.gsub(/\\/, "/")
      end

    end
  end
end
