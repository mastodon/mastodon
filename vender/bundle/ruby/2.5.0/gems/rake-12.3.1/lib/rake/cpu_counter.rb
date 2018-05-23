# frozen_string_literal: true
module Rake

  # Based on a script at:
  #   http://stackoverflow.com/questions/891537/ruby-detect-number-of-cpus-installed
  class CpuCounter # :nodoc: all
    def self.count
      new.count_with_default
    end

    def count_with_default(default=4)
      count || default
    rescue StandardError
      default
    end

    begin
      require "etc"
    rescue LoadError
    else
      if Etc.respond_to?(:nprocessors)
        def count
          return Etc.nprocessors
        end
      end
    end
  end
end

unless Rake::CpuCounter.method_defined?(:count)
  Rake::CpuCounter.class_eval <<-'end;', __FILE__, __LINE__+1
    require 'rbconfig'

    def count
      if defined?(Java::Java)
        count_via_java_runtime
      else
        case RbConfig::CONFIG['host_os']
        when /linux/
          count_via_cpuinfo
        when /darwin|bsd/
          count_via_sysctl
        when /mswin|mingw/
          count_via_win32
        else
          # Try everything
          count_via_win32 ||
          count_via_sysctl ||
          count_via_cpuinfo
        end
      end
    end

    def count_via_java_runtime
      Java::Java.lang.Runtime.getRuntime.availableProcessors
    rescue StandardError
      nil
    end

    def count_via_win32
      require 'win32ole'
      wmi = WIN32OLE.connect("winmgmts://")
      cpu = wmi.ExecQuery("select NumberOfCores from Win32_Processor") # TODO count hyper-threaded in this
      cpu.to_enum.first.NumberOfCores
    rescue StandardError, LoadError
      nil
    end

    def count_via_cpuinfo
      open('/proc/cpuinfo') { |f| f.readlines }.grep(/processor/).size
    rescue StandardError
      nil
    end

    def count_via_sysctl
      run 'sysctl', '-n', 'hw.ncpu'
    end

    def run(command, *args)
      cmd = resolve_command(command)
      if cmd
        IO.popen [cmd, *args] do |io|
          io.read.to_i
        end
      else
        nil
      end
    end

    def resolve_command(command)
      look_for_command("/usr/sbin", command) ||
        look_for_command("/sbin", command) ||
        in_path_command(command)
    end

    def look_for_command(dir, command)
      path = File.join(dir, command)
      File.exist?(path) ? path : nil
    end

    def in_path_command(command)
      IO.popen ['which', command] do |io|
        io.eof? ? nil : command
      end
    end
  end;
end
