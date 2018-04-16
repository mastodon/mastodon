# encoding: utf-8
# frozen_string_literal: true

module TTY
  class Command
    # Encapsulates the information on the command executed
    #
    # @api public
    class Result
      include Enumerable

      # All data written out to process's stdout stream
      attr_reader :out
      alias stdout out

      # All data written out to process's stdin stream
      attr_reader :err
      alias stderr err

      # Total command execution time
      attr_reader :runtime

      # Create a result
      #
      # @api public
      def initialize(status, out, err, runtime = 0.0)
        @status = status
        @out    = out
        @err    = err
        @runtime = runtime
      end

      # Enumerate over output lines
      #
      # @param [String] separator
      #
      # @api public
      def each(separator = nil)
        sep = separator || TTY::Command.record_separator
        return unless @out
        elements = @out.split(sep)
        if block_given?
          elements.each { |line| yield(line) }
        else
          elements.to_enum
        end
      end

      # Information on how the process exited
      #
      # @api public
      def exit_status
        @status
      end
      alias exitstatus exit_status
      alias status exit_status

      def to_i
        @status
      end

      def to_s
        @status.to_s
      end

      def to_ary
        [@out, @err]
      end

      def exited?
        @status != nil
      end
      alias complete? exited?

      def success?
        exited? ?  @status.zero? : false
      end

      def failure?
        !success?
      end
      alias failed? failure?

      def ==(other)
        return false unless other.is_a?(TTY::Command::Result)
        @status == other.to_i && to_ary == other.to_ary
      end
    end # Result
  end # Command
end # TTY
