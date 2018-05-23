require 'ffi'

module Puma
  module JRubyRestart
    extend FFI::Library
    ffi_lib 'c'

    attach_function :execlp, [:string, :varargs], :int
    attach_function :chdir, [:string], :int
    attach_function :fork, [], :int
    attach_function :exit, [:int], :void
    attach_function :setsid, [], :int

    def self.chdir_exec(dir, argv)
      chdir(dir)
      cmd = argv.first
      argv = ([:string] * argv.size).zip(argv).flatten
      argv << :string
      argv << nil
      execlp(cmd, *argv)
      raise SystemCallError.new(FFI.errno)
    end

    PermKey = 'PUMA_DAEMON_PERM'
    RestartKey = 'PUMA_DAEMON_RESTART'

    # Called to tell things "Your now always in daemon mode,
    # don't try to reenter it."
    #
    def self.perm_daemonize
      ENV[PermKey] = "1"
    end

    def self.daemon?
      ENV.key?(PermKey) || ENV.key?(RestartKey)
    end

    def self.daemon_init
      return true if ENV.key?(PermKey)

      return false unless ENV.key? RestartKey

      master = ENV[RestartKey]

      # In case the master disappears early
      begin
        Process.kill "SIGUSR2", master.to_i
      rescue SystemCallError => e
      end

      ENV[RestartKey] = ""

      setsid

      null = File.open "/dev/null", "w+"
      STDIN.reopen null
      STDOUT.reopen null
      STDERR.reopen null

      true
    end

    def self.daemon_start(dir, argv)
      ENV[RestartKey] = Process.pid.to_s

      if k = ENV['PUMA_JRUBY_DAEMON_OPTS']
        ENV['JRUBY_OPTS'] = k
      end

      cmd = argv.first
      argv = ([:string] * argv.size).zip(argv).flatten
      argv << :string
      argv << nil

      chdir(dir)
      ret = fork
      return ret if ret != 0
      execlp(cmd, *argv)
      raise SystemCallError.new(FFI.errno)
    end
  end
end
