# coding: UTF-8

module Terrapin
  class CommandLine
    class << self
      attr_accessor :logger, :runner

      def path
        @supplemental_path
      end

      def path=(supplemental_path)
        @supplemental_path = Array(supplemental_path).
          flatten.
          join(OS.path_separator)
      end

      def environment
        @supplemental_environment ||= {}
      end

      def runner
        @runner || best_runner
      end

      def runner_options
        @default_runner_options ||= {}
      end

      def fake!
        @runner = FakeRunner.new
      end

      def unfake!
        @runner = nil
      end

      private

      def best_runner
        [PosixRunner, ProcessRunner, BackticksRunner].detect do |runner|
          runner.supported?
        end.new
      end
    end

    @environment = {}

    attr_reader :exit_status, :runner

    def initialize(binary, params = "", options = {})
      @binary            = binary.dup
      @params            = params.dup
      @options           = options.dup
      @runner            = @options.delete(:runner) || self.class.runner
      @logger            = @options.delete(:logger) || self.class.logger
      @swallow_stderr    = @options.delete(:swallow_stderr)
      @expected_outcodes = @options.delete(:expected_outcodes) || [0]
      @environment       = @options.delete(:environment) || {}
      @runner_options    = @options.delete(:runner_options) || {}
    end

    def command(interpolations = {})
      cmd = [path_prefix, @binary, interpolate(@params, interpolations)]
      cmd << bit_bucket if @swallow_stderr
      cmd.join(" ").strip
    end

    def run(interpolations = {})
      @exit_status = nil
      begin
        full_command = command(interpolations)
        log("#{colored("Command")} :: #{full_command}")
        @output = execute(full_command)
      rescue Errno::ENOENT => e
        raise Terrapin::CommandNotFoundError, e.message
      ensure
        @exit_status = $?.respond_to?(:exitstatus) ? $?.exitstatus : 0
      end

      if @exit_status == 127
        raise Terrapin::CommandNotFoundError
      end

      unless @expected_outcodes.include?(@exit_status)
        message = [
          "Command '#{full_command}' returned #{@exit_status}. Expected #{@expected_outcodes.join(", ")}",
          "Here is the command output: STDOUT:\n", command_output,
          "\nSTDERR:\n", command_error_output
        ].join("\n")
        raise Terrapin::ExitStatusError, message
      end
      command_output
    end

    def command_output
      output.output
    end

    def command_error_output
      output.error_output
    end

    def output
      @output || Output.new
    end

    private

    def colored(text, ansi_color = "\e[32m")
      if @logger && @logger.respond_to?(:tty?) && @logger.tty?
        "#{ansi_color}#{text}\e[0m"
      else
        text
      end
    end

    def log(text)
      if @logger
        @logger.info(text)
      end
    end

    def path_prefix
      if !self.class.path.nil? && !self.class.path.empty?
        os_path_prefix
      end
    end

    def os_path_prefix
      if OS.unix?
        unix_path_prefix
      else
        windows_path_prefix
      end
    end

    def unix_path_prefix
      "PATH=#{self.class.path}#{OS.path_separator}$PATH;"
    end

    def windows_path_prefix
      "SET PATH=#{self.class.path}#{OS.path_separator}%PATH% &"
    end

    def execute(command)
      runner.call(command, environment, runner_options)
    end

    def environment
      self.class.environment.merge(@environment)
    end

    def runner_options
      self.class.runner_options.merge(@runner_options)
    end

    def interpolate(pattern, interpolations)
      interpolations = stringify_keys(interpolations)
      pattern.gsub(/:\{?(\w+)\b\}?/) do |match|
        key = match.tr(":{}", "")
        if interpolations.key?(key)
          shell_quote_all_values(interpolations[key])
        else
          match
        end
      end
    end

    def stringify_keys(hash)
      Hash[hash.map{ |k, v| [k.to_s, v] }]
    end

    def shell_quote_all_values(values)
      Array(values).map(&method(:shell_quote)).join(" ")
    end

    def shell_quote(string)
      return "" if string.nil?
      string = string.to_s if string.respond_to? :to_s

      if OS.unix?
        if string.empty?
          "''"
        else
          string.split("'", -1).map{|m| "'#{m}'" }.join("\\'")
        end
      else
        %{"#{string}"}
      end
    end

    def bit_bucket
      OS.unix? ? "2>/dev/null" : "2>NUL"
    end
  end
end
