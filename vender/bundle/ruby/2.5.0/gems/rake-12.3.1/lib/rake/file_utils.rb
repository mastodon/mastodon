# frozen_string_literal: true
require "rbconfig"
require "fileutils"

#--
# This a FileUtils extension that defines several additional commands to be
# added to the FileUtils utility functions.
module FileUtils
  # Path to the currently running Ruby program
  RUBY = ENV["RUBY"] || File.join(
    RbConfig::CONFIG["bindir"],
    RbConfig::CONFIG["ruby_install_name"] + RbConfig::CONFIG["EXEEXT"]).
    sub(/.*\s.*/m, '"\&"')

  # Run the system command +cmd+.  If multiple arguments are given the command
  # is run directly (without the shell, same semantics as Kernel::exec and
  # Kernel::system).
  #
  # It is recommended you use the multiple argument form over interpolating
  # user input for both usability and security reasons.  With the multiple
  # argument form you can easily process files with spaces or other shell
  # reserved characters in them.  With the multiple argument form your rake
  # tasks are not vulnerable to users providing an argument like
  # <code>; rm # -rf /</code>.
  #
  # If a block is given, upon command completion the block is called with an
  # OK flag (true on a zero exit status) and a Process::Status object.
  # Without a block a RuntimeError is raised when the command exits non-zero.
  #
  # Examples:
  #
  #   sh 'ls -ltr'
  #
  #   sh 'ls', 'file with spaces'
  #
  #   # check exit status after command runs
  #   sh %{grep pattern file} do |ok, res|
  #     if ! ok
  #       puts "pattern not found (status = #{res.exitstatus})"
  #     end
  #   end
  #
  def sh(*cmd, &block)
    options = (Hash === cmd.last) ? cmd.pop : {}
    shell_runner = block_given? ? block : create_shell_runner(cmd)

    set_verbose_option(options)
    verbose = options.delete :verbose
    noop    = options.delete(:noop) || Rake::FileUtilsExt.nowrite_flag

    Rake.rake_output_message sh_show_command cmd if verbose

    unless noop
      res = (Hash === cmd.last) ? system(*cmd) : system(*cmd, options)
      status = $?
      status = Rake::PseudoStatus.new(1) if !res && status.nil?
      shell_runner.call(res, status)
    end
  end

  def create_shell_runner(cmd) # :nodoc:
    show_command = sh_show_command cmd
    show_command = show_command[0, 42] + "..." unless $trace

    lambda do |ok, status|
      ok or
        fail "Command failed with status (#{status.exitstatus}): " +
        "[#{show_command}]"
    end
  end
  private :create_shell_runner

  def sh_show_command(cmd) # :nodoc:
    cmd = cmd.dup

    if Hash === cmd.first
      env = cmd.first
      env = env.map { |name, value| "#{name}=#{value}" }.join " "
      cmd[0] = env
    end

    cmd.join " "
  end
  private :sh_show_command

  def set_verbose_option(options) # :nodoc:
    unless options.key? :verbose
      options[:verbose] =
        (Rake::FileUtilsExt.verbose_flag == Rake::FileUtilsExt::DEFAULT) ||
        Rake::FileUtilsExt.verbose_flag
    end
  end
  private :set_verbose_option

  # Run a Ruby interpreter with the given arguments.
  #
  # Example:
  #   ruby %{-pe '$_.upcase!' <README}
  #
  def ruby(*args, &block)
    options = (Hash === args.last) ? args.pop : {}
    if args.length > 1
      sh(*([RUBY] + args + [options]), &block)
    else
      sh("#{RUBY} #{args.first}", options, &block)
    end
  end

  LN_SUPPORTED = [true]

  #  Attempt to do a normal file link, but fall back to a copy if the link
  #  fails.
  def safe_ln(*args)
    if ! LN_SUPPORTED[0]
      cp(*args)
    else
      begin
        ln(*args)
      rescue StandardError, NotImplementedError
        LN_SUPPORTED[0] = false
        cp(*args)
      end
    end
  end

  # Split a file path into individual directory names.
  #
  # Example:
  #   split_all("a/b/c") =>  ['a', 'b', 'c']
  #
  def split_all(path)
    head, tail = File.split(path)
    return [tail] if head == "." || tail == "/"
    return [head, tail] if head == "/"
    return split_all(head) + [tail]
  end
end
