# frozen_string_literal: false

require 'fcntl'

module Terrapin
  module MultiPipeExtensions
    def initialize
      @stdout_in, @stdout_out = IO.pipe
      @stderr_in, @stderr_out = IO.pipe

      clear_nonblocking_flags!
    end

    def pipe_options
      # Add some flags to explicitly close the other end of the pipes
      { :out => @stdout_out, :err => @stderr_out, @stdout_in => :close, @stderr_in => :close }
    end

    def read
      # While we are patching Terrapin, fix child process potentially getting stuck on writing
      # to stderr.

      @stdout_output = +''
      @stderr_output = +''

      fds_to_read = [@stdout_in, @stderr_in]
      until fds_to_read.empty?
        rs, = IO.select(fds_to_read)

        read_nonblocking!(@stdout_in, @stdout_output, fds_to_read) if rs.include?(@stdout_in)
        read_nonblocking!(@stderr_in, @stderr_output, fds_to_read) if rs.include?(@stderr_in)
      end
    end

    private

    # @param [IO] io IO Stream to read until there is nothing to read
    # @param [String] result Mutable string to which read values will be appended to
    # @param [Array<IO>] fds_to_read Mutable array from which `io` should be removed on EOF
    def read_nonblocking!(io, result, fds_to_read)
      while (partial_result = io.read_nonblock(8192))
        result << partial_result
      end
    rescue IO::WaitReadable
      # Do nothing
    rescue EOFError
      fds_to_read.delete(io)
    end

    def clear_nonblocking_flags!
      # Ruby 3.0 sets pipes to non-blocking mode, and resets the flags as
      # needed when calling fork/exec-related syscalls, but posix-spawn does
      # not currently do that, so we need to do it manually for the time being
      # so that the child process do not error out when the buffers are full.
      stdout_flags = @stdout_out.fcntl(Fcntl::F_GETFL)
      @stdout_out.fcntl(Fcntl::F_SETFL, stdout_flags & ~Fcntl::O_NONBLOCK) if stdout_flags & Fcntl::O_NONBLOCK

      stderr_flags = @stderr_out.fcntl(Fcntl::F_GETFL)
      @stderr_out.fcntl(Fcntl::F_SETFL, stderr_flags & ~Fcntl::O_NONBLOCK) if stderr_flags & Fcntl::O_NONBLOCK
    rescue NameError, NotImplementedError, Errno::EINVAL
      # Probably on windows, where pipes are blocking by default
    end
  end
end

Terrapin::CommandLine::MultiPipe.prepend(Terrapin::MultiPipeExtensions)
