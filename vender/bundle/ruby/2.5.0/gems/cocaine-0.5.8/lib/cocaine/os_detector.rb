# coding: UTF-8

module Cocaine
  class OSDetector
    def java?
      arch =~ /java/
    end

    def unix?
      RbConfig::CONFIG['host_os'] !~ /mswin|mingw/
    end

    def windows?
      !unix?
    end

    def path_separator
      File::PATH_SEPARATOR
    end

    def arch
      RUBY_PLATFORM
    end
  end

  OS = OSDetector.new
end
