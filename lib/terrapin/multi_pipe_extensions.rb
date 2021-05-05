# frozen_string_literal: false
# Fix adapted from https://github.com/thoughtbot/terrapin/pull/5

module Terrapin
  module MultiPipeExtensions
    def read
      read_streams(@stdout_in, @stderr_in)
    end

    def close_read
      begin
        @stdout_in.close
      rescue IOError
        # Do nothing
      end

      begin
        @stderr_in.close
      rescue IOError
        # Do nothing
      end
    end

    def read_streams(output, error)
      @stdout_output = ''
      @stderr_output = ''

      read_fds = [output, error]

      until read_fds.empty?
        to_read, = IO.select(read_fds)

        if to_read.include?(output)
          @stdout_output << read_stream(output)
          read_fds.delete(output) if output.closed?
        end

        if to_read.include?(error)
          @stderr_output << read_stream(error)
          read_fds.delete(error) if error.closed?
        end
      end
    end

    def read_stream(io)
      result = ''

      begin
        while (partial_result = io.read_nonblock(8192))
          result << partial_result
        end
      rescue EOFError, Errno::EPIPE
        io.close
      rescue Errno::EINTR, Errno::EWOULDBLOCK, Errno::EAGAIN
        # Do nothing
      end

      result
    end
  end
end

Terrapin::CommandLine::MultiPipe.prepend(Terrapin::MultiPipeExtensions)
