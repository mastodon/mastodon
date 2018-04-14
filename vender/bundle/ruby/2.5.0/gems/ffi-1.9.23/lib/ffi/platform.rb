#
# Copyright (C) 2008, 2009 Wayne Meissner
#
# This file is part of ruby-ffi.
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the Ruby FFI project nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.#

require 'rbconfig'
module FFI
  class PlatformError < LoadError; end

  # This module defines different constants and class methods to play with
  # various platforms.
  module Platform
    OS = case RbConfig::CONFIG['host_os'].downcase
    when /linux/
      "linux"
    when /darwin/
      "darwin"
    when /freebsd/
      "freebsd"
    when /netbsd/
      "netbsd"
    when /openbsd/
      "openbsd"
    when /sunos|solaris/
      "solaris"
    when /mingw|mswin/
      "windows"
    else
      RbConfig::CONFIG['host_os'].downcase
    end

    ARCH = case CPU.downcase
    when /amd64|x86_64/
      "x86_64"
    when /i?86|x86|i86pc/
      "i386"
    when /ppc64|powerpc64/
      "powerpc64"
    when /ppc|powerpc/
      "powerpc"
    when /sparcv9|sparc64/
      "sparcv9"
    else
      case RbConfig::CONFIG['host_cpu']
      when /^arm/
        "arm"
      else
        RbConfig::CONFIG['host_cpu']
      end
    end

    private
    # @param [String) os
    # @return [Boolean]
    # Test if current OS is +os+.
    def self.is_os(os)
      OS == os
    end

    NAME = "#{ARCH}-#{OS}"
    IS_GNU = defined?(GNU_LIBC)
    IS_LINUX = is_os("linux")
    IS_MAC = is_os("darwin")
    IS_FREEBSD = is_os("freebsd")
    IS_NETBSD = is_os("netbsd")
    IS_OPENBSD = is_os("openbsd")
    IS_SOLARIS = is_os("solaris")
    IS_WINDOWS = is_os("windows")
    IS_BSD = IS_MAC || IS_FREEBSD || IS_NETBSD || IS_OPENBSD
    CONF_DIR = File.join(File.dirname(__FILE__), 'platform', NAME)

    public

    LIBPREFIX = case OS
    when /windows|msys/
      ''
    when /cygwin/
      'cyg'
    else
      'lib'
    end

    LIBSUFFIX = case OS
    when /darwin/
      'dylib'
    when /linux|bsd|solaris/
      'so'
    when /windows|cygwin|msys/
      'dll'
    else
      # Punt and just assume a sane unix (i.e. anything but AIX)
      'so'
    end

    LIBC = if IS_WINDOWS
      RbConfig::CONFIG['RUBY_SO_NAME'].split('-')[-2] + '.dll'
    elsif IS_GNU
      GNU_LIBC
    elsif OS == 'cygwin'
      "cygwin1.dll"
    elsif OS == 'msys'
      # Not sure how msys 1.0 behaves, tested on MSYS2.
      "msys-2.0.dll"
    else
      "#{LIBPREFIX}c.#{LIBSUFFIX}"
    end

    # Test if current OS is a *BSD (include MAC)
    # @return [Boolean]
    def self.bsd?
      IS_BSD
    end

    # Test if current OS is Windows
    # @return [Boolean]
    def self.windows?
      IS_WINDOWS
    end

    # Test if current OS is Mac OS
    # @return [Boolean]
    def self.mac?
      IS_MAC
    end

    # Test if current OS is Solaris (Sun OS)
    # @return [Boolean]
    def self.solaris?
      IS_SOLARIS
    end

    # Test if current OS is a unix OS
    # @return [Boolean]
    def self.unix?
      !IS_WINDOWS
    end
  end
end

