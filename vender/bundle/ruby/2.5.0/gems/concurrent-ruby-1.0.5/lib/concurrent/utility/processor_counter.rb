require 'rbconfig'
require 'concurrent/delay'

module Concurrent
  module Utility

    # @!visibility private
    class ProcessorCounter
      def initialize
        @processor_count          = Delay.new { compute_processor_count }
        @physical_processor_count = Delay.new { compute_physical_processor_count }
      end

      # Number of processors seen by the OS and used for process scheduling. For
      # performance reasons the calculated value will be memoized on the first
      # call.
      #
      # When running under JRuby the Java runtime call
      # `java.lang.Runtime.getRuntime.availableProcessors` will be used. According
      # to the Java documentation this "value may change during a particular
      # invocation of the virtual machine... [applications] should therefore
      # occasionally poll this property." Subsequently the result will NOT be
      # memoized under JRuby.
      #
      # On Windows the Win32 API will be queried for the
      # `NumberOfLogicalProcessors from Win32_Processor`. This will return the
      # total number "logical processors for the current instance of the
      # processor", which taked into account hyperthreading.
      #
      # * AIX: /usr/sbin/pmcycles (AIX 5+), /usr/sbin/lsdev
      # * Alpha: /usr/bin/nproc (/proc/cpuinfo exists but cannot be used)
      # * BSD: /sbin/sysctl
      # * Cygwin: /proc/cpuinfo
      # * Darwin: /usr/bin/hwprefs, /usr/sbin/sysctl
      # * HP-UX: /usr/sbin/ioscan
      # * IRIX: /usr/sbin/sysconf
      # * Linux: /proc/cpuinfo
      # * Minix 3+: /proc/cpuinfo
      # * Solaris: /usr/sbin/psrinfo
      # * Tru64 UNIX: /usr/sbin/psrinfo
      # * UnixWare: /usr/sbin/psrinfo
      #
      # @return [Integer] number of processors seen by the OS or Java runtime
      #
      # @see https://github.com/grosser/parallel/blob/4fc8b89d08c7091fe0419ca8fba1ec3ce5a8d185/lib/parallel.rb
      #
      # @see http://docs.oracle.com/javase/6/docs/api/java/lang/Runtime.html#availableProcessors()
      # @see http://msdn.microsoft.com/en-us/library/aa394373(v=vs.85).aspx
      def processor_count
        @processor_count.value
      end

      # Number of physical processor cores on the current system. For performance
      # reasons the calculated value will be memoized on the first call.
      #
      # On Windows the Win32 API will be queried for the `NumberOfCores from
      # Win32_Processor`. This will return the total number "of cores for the
      # current instance of the processor." On Unix-like operating systems either
      # the `hwprefs` or `sysctl` utility will be called in a subshell and the
      # returned value will be used. In the rare case where none of these methods
      # work or an exception is raised the function will simply return 1.
      #
      # @return [Integer] number physical processor cores on the current system
      #
      # @see https://github.com/grosser/parallel/blob/4fc8b89d08c7091fe0419ca8fba1ec3ce5a8d185/lib/parallel.rb
      #
      # @see http://msdn.microsoft.com/en-us/library/aa394373(v=vs.85).aspx
      # @see http://www.unix.com/man-page/osx/1/HWPREFS/
      # @see http://linux.die.net/man/8/sysctl
      def physical_processor_count
        @physical_processor_count.value
      end

      private

      def compute_processor_count
        if Concurrent.on_jruby?
          java.lang.Runtime.getRuntime.availableProcessors
        elsif Concurrent.on_truffle?
          Truffle::Primitive.logical_processors
        else
          os_name = RbConfig::CONFIG["target_os"]
          if os_name =~ /mingw|mswin/
            require 'win32ole'
            result = WIN32OLE.connect("winmgmts://").ExecQuery(
              "select NumberOfLogicalProcessors from Win32_Processor")
            result.to_enum.collect(&:NumberOfLogicalProcessors).reduce(:+)
          elsif File.readable?("/proc/cpuinfo") && (cpuinfo_count = IO.read("/proc/cpuinfo").scan(/^processor/).size) > 0
            cpuinfo_count
          elsif File.executable?("/usr/bin/nproc")
            IO.popen("/usr/bin/nproc --all", &:read).to_i
          elsif File.executable?("/usr/bin/hwprefs")
            IO.popen("/usr/bin/hwprefs thread_count", &:read).to_i
          elsif File.executable?("/usr/sbin/psrinfo")
            IO.popen("/usr/sbin/psrinfo", &:read).scan(/^.*on-*line/).size
          elsif File.executable?("/usr/sbin/ioscan")
            IO.popen("/usr/sbin/ioscan -kC processor", &:read).scan(/^.*processor/).size
          elsif File.executable?("/usr/sbin/pmcycles")
            IO.popen("/usr/sbin/pmcycles -m", &:read).count("\n")
          elsif File.executable?("/usr/sbin/lsdev")
            IO.popen("/usr/sbin/lsdev -Cc processor -S 1", &:read).count("\n")
          elsif File.executable?("/usr/sbin/sysconf") and os_name =~ /irix/i
            IO.popen("/usr/sbin/sysconf NPROC_ONLN", &:read).to_i
          elsif File.executable?("/usr/sbin/sysctl")
            IO.popen("/usr/sbin/sysctl -n hw.ncpu", &:read).to_i
          elsif File.executable?("/sbin/sysctl")
            IO.popen("/sbin/sysctl -n hw.ncpu", &:read).to_i
          else
            # TODO (pitr-ch 05-Nov-2016): warn about failures
            1
          end
        end
      rescue
        return 1
      end

      def compute_physical_processor_count
        ppc = case RbConfig::CONFIG["target_os"]
              when /darwin1/
                IO.popen("/usr/sbin/sysctl -n hw.physicalcpu", &:read).to_i
              when /linux/
                cores = {} # unique physical ID / core ID combinations
                phy   = 0
                IO.read("/proc/cpuinfo").scan(/^physical id.*|^core id.*/) do |ln|
                  if ln.start_with?("physical")
                    phy = ln[/\d+/]
                  elsif ln.start_with?("core")
                    cid        = phy + ":" + ln[/\d+/]
                    cores[cid] = true if not cores[cid]
                  end
                end
                cores.count
              when /mswin|mingw/
                require 'win32ole'
                result_set = WIN32OLE.connect("winmgmts://").ExecQuery(
                  "select NumberOfCores from Win32_Processor")
                result_set.to_enum.collect(&:NumberOfCores).reduce(:+)
              else
                processor_count
              end
        # fall back to logical count if physical info is invalid
        ppc > 0 ? ppc : processor_count
      rescue
        return 1
      end
    end
  end

  # create the default ProcessorCounter on load
  @processor_counter = Utility::ProcessorCounter.new
  singleton_class.send :attr_reader, :processor_counter

  def self.processor_count
    processor_counter.processor_count
  end

  def self.physical_processor_count
    processor_counter.physical_processor_count
  end
end
