# frozen_string_literal: true

require "socket"
require "nio/version"

# New I/O for Ruby
module NIO
  # NIO implementation, one of the following (as a string):
  # * select: in pure Ruby using Kernel.select
  # * libev: as a C extension using libev
  # * java: using Java NIO
  def self.engine
    ENGINE
  end
end

if ENV["NIO4R_PURE"] == "true" || (Gem.win_platform? && !defined?(JRUBY_VERSION))
  require "nio/monitor"
  require "nio/selector"
  require "nio/bytebuffer"
  NIO::ENGINE = "ruby".freeze
else
  require "nio4r_ext"

  if defined?(JRUBY_VERSION)
    require "java"
    require "jruby"
    org.nio4r.Nio4r.new.load(JRuby.runtime, false)
    NIO::ENGINE = "java".freeze
  else
    NIO::ENGINE = "libev".freeze
  end
end
