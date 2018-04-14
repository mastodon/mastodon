# frozen_string_literal: true
module Rake
  module Backtrace # :nodoc: all
    SYS_KEYS  = RbConfig::CONFIG.keys.grep(/(?:[a-z]prefix|libdir)\z/)
    SYS_PATHS = RbConfig::CONFIG.values_at(*SYS_KEYS).uniq +
      [ File.join(File.dirname(__FILE__), "..") ]

    SUPPRESSED_PATHS = SYS_PATHS.
      map { |s| s.tr("\\", "/") }.
      map { |f| File.expand_path(f) }.
      reject { |s| s.nil? || s =~ /^ *$/ }
    SUPPRESSED_PATHS_RE = SUPPRESSED_PATHS.map { |f| Regexp.quote(f) }.join("|")
    SUPPRESSED_PATHS_RE << "|^org\\/jruby\\/\\w+\\.java" if
      Object.const_defined?(:RUBY_ENGINE) and RUBY_ENGINE == "jruby"

    SUPPRESS_PATTERN = %r!(\A(#{SUPPRESSED_PATHS_RE})|bin/rake:\d+)!i

    def self.collapse(backtrace)
      pattern = Rake.application.options.suppress_backtrace_pattern ||
                SUPPRESS_PATTERN
      backtrace.reject { |elem| elem =~ pattern }
    end
  end
end
