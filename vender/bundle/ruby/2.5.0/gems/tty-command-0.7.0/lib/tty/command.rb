# frozen_string_literal: true

require 'rbconfig'

require_relative 'command/cmd'
require_relative 'command/exit_error'
require_relative 'command/dry_runner'
require_relative 'command/process_runner'
require_relative 'command/printers/null'
require_relative 'command/printers/pretty'
require_relative 'command/printers/progress'
require_relative 'command/printers/quiet'
require_relative 'command/version'

module TTY
  class Command
    ExecuteError = Class.new(StandardError)

    TimeoutExceeded = Class.new(StandardError)

    # Path to the current Ruby
    RUBY = ENV['RUBY'] || ::File.join(
      RbConfig::CONFIG['bindir'],
      RbConfig::CONFIG['ruby_install_name'] + RbConfig::CONFIG['EXEEXT']
    )

    WIN_PLATFORMS = /cygwin|mswin|mingw|bccwin|wince|emx/.freeze

    def self.record_separator
      @record_separator ||= $/
    end

    def self.record_separator=(sep)
      @record_separator = sep
    end

    def self.windows?
      !!(RbConfig::CONFIG['host_os'] =~ WIN_PLATFORMS)
    end

    attr_reader :printer

    # Initialize a Command object
    #
    # @param [Hash] options
    # @option options [IO] :output
    #   the stream to which printer prints, defaults to stdout
    # @option options [Symbol] :printer
    #   the printer to use for output logging, defaults to :pretty
    # @option options [Symbol] :dry_run
    #   the mode for executing command
    #
    # @api public
    def initialize(**options)
      @output = options.fetch(:output) { $stdout }
      @color   = options.fetch(:color) { true }
      @uuid    = options.fetch(:uuid) { true }
      @printer_name = options.fetch(:printer) { :pretty }
      @dry_run = options.fetch(:dry_run) { false }
      @printer = use_printer(@printer_name, color: @color, uuid: @uuid)
      @cmd_options = {}
      @cmd_options[:pty] = true if options[:pty]
      @cmd_options[:binmode] = true if options[:binmode]
      @cmd_options[:timeout] = options[:timeout] if options[:timeout]
    end

    # Start external executable in a child process
    #
    # @example
    #   cmd.run(command, [argv1, ..., argvN], [options])
    #
    # @example
    #   cmd.run(command, ...) do |result|
    #     ...
    #   end
    #
    # @param [String] command
    #   the command to run
    #
    # @param [Array[String]] argv
    #   an array of string arguments
    #
    # @param [Hash] options
    #   hash of operations to perform
    # @option options [String] :chdir
    #   The current directory.
    # @option options [Integer] :timeout
    #   Maximum number of seconds to allow the process
    #   to run before aborting with a TimeoutExceeded
    #   exception.
    # @option options [Symbol] :signal
    #   Signal used on timeout, SIGKILL by default
    #
    # @yield [out, err]
    #   Yields stdout and stderr output whenever available
    #
    # @raise [ExitError]
    #   raised when command exits with non-zero code
    #
    # @api public
    def run(*args, &block)
      cmd = command(*args)
      result = execute_command(cmd, &block)
      if result && result.failure?
        raise ExitError.new(cmd.to_command, result)
      end
      result
    end

    # Start external executable without raising ExitError
    #
    # @example
    #   cmd.run!(command, [argv1, ..., argvN], [options])
    #
    # @api public
    def run!(*args, &block)
      cmd = command(*args)
      execute_command(cmd, &block)
    end

    # Wait on long running script until output matches a specific pattern
    #
    # @example
    #   cmd.wait 'tail -f /var/log/php.log', /something happened/
    #
    # @api public
    def wait(*args)
      pattern = args.pop
      unless pattern
        raise ArgumentError, 'Please provide condition to wait for'
      end

      run(*args) do |out, _|
        raise if out =~ /#{pattern}/
      end
    rescue ExitError
      # noop
    end

    # Execute shell test command
    #
    # @api public
    def test(*args)
      run!(:test, *args).success?
    end

    # Run Ruby interperter with the given arguments
    #
    # @example
    #   ruby %q{-e "puts 'Hello world'"}
    #
    # @api public
    def ruby(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      if args.length > 1
        run(*([RUBY] + args + [options]), &block)
      else
        run("#{RUBY} #{args.first}", options, &block)
      end
    end

    # Check if in dry mode
    #
    # @return [Boolean]
    #
    # @public
    def dry_run?
      @dry_run
    end

    private

    # @api private
    def command(*args)
      cmd = Cmd.new(*args)
      cmd.update(@cmd_options)
      cmd
    end

    # @api private
    def execute_command(cmd, &block)
      dry_run = @dry_run || cmd.options[:dry_run] || false
      @runner = select_runner(dry_run).new(cmd, @printer, &block)
      @runner.run!
    end

    # @api private
    def use_printer(class_or_name, options)
      if class_or_name.is_a?(TTY::Command::Printers::Abstract)
        return class_or_name
      end

      if class_or_name.is_a?(Class)
        class_or_name
      else
        find_printer_class(class_or_name)
      end.new(@output, options)
    end

    # Find printer class or fail
    #
    # @raise [ArgumentError]
    #
    # @api private
    def find_printer_class(name)
      const_name = name.to_s.capitalize.to_sym
      if const_name.empty? || !TTY::Command::Printers.const_defined?(const_name)
        raise ArgumentError, %(Unknown printer type "#{name}")
      end
      TTY::Command::Printers.const_get(const_name)
    end

    # @api private
    def select_runner(dry_run)
      if dry_run
        DryRunner
      else
        ProcessRunner
      end
    end
  end # Command
end # TTY
