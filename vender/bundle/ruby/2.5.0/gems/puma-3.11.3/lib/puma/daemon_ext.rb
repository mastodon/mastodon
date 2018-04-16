module Process

  # This overrides the default version because it is broken if it
  # exists.

  if respond_to? :daemon
    class << self
      remove_method :daemon
    end
  end

  def self.daemon(nochdir=false, noclose=false)
    exit if fork                     # Parent exits, child continues.

    Process.setsid                   # Become session leader.

    exit if fork                     # Zap session leader. See [1].

    Dir.chdir "/" unless nochdir     # Release old working directory.

    if !noclose
      STDIN.reopen File.open("/dev/null", "r")

      null_out = File.open "/dev/null", "w"
      STDOUT.reopen null_out
      STDERR.reopen null_out
    end

    0
  end
end
