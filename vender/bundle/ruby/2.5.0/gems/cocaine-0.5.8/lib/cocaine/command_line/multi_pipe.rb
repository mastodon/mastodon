module Cocaine
  class CommandLine
    class MultiPipe
      def initialize
        @stdout_in, @stdout_out = IO.pipe
        @stderr_in, @stderr_out = IO.pipe
      end

      def pipe_options
        { out: @stdout_out, err: @stderr_out }
      end

      def output
        Output.new(@stdout_output, @stderr_output)
      end

      def read_and_then(&block)
        close_write
        read
        block.call
        close_read
      end

      private

      def close_write
        @stdout_out.close
        @stderr_out.close
      end

      def read
        @stdout_output = read_stream(@stdout_in)
        @stderr_output = read_stream(@stderr_in)
      end

      def close_read
        @stdout_in.close
        @stderr_in.close
      end

      def read_stream(io)
        result = ""
        while partial_result = io.read(8192)
          result << partial_result
        end
        result
      end
    end
  end
end
