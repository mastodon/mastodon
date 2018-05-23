# encoding: utf-8
# frozen_string_literal: true

module TTY
  class Command
    # An ExitError reports an unsuccessful exit by command.
    #
    # The error message includes:
    #  * the name of command executed
    #  * the exit status
    #  * stdout bytes
    #  * stderr bytes
    #
    # @api private
    class ExitError < RuntimeError
      def initialize(cmd_name, result)
        super(info(cmd_name, result))
      end

      def info(cmd_name, result)
        "Running `#{cmd_name}` failed with\n" \
        "  exit status: #{result.exit_status}\n" \
        "  stdout: #{extract_output(result.out)}\n" \
        "  stderr: #{extract_output(result.err)}\n"
      end

      def extract_output(value)
        (value || '').strip.empty? ? 'Nothing written' : value.strip
      end
    end # ExitError
  end # Command
end # TTY
