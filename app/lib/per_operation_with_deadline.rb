# frozen_string_literal: true

require 'socket'

# Use our own timeout class to avoid using HTTP.rb's timeout block
# around the Socket#open method, since we use our own timeout blocks inside
# that method
#
# Also changes how the read timeout behaves so that it is cumulative (closer
# to HTTP::Timeout::Global, but still having distinct timeouts for other
# operation types)
class PerOperationWithDeadline < HTTP::Timeout::PerOperation
  READ_DEADLINE = 30

  def initialize(*args)
    super

    @read_deadline = options.fetch(:read_deadline, READ_DEADLINE)
  end

  def connect(socket_class, host, port, nodelay = false) # rubocop:disable Style/OptionalBooleanParameter
    @socket = socket_class.open(host, port)
    @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1) if nodelay
  end

  # Reset deadline when the connection is re-used for different requests
  def reset_counter
    @deadline = nil
  end

  # Read data from the socket
  def readpartial(size, buffer = nil)
    @deadline ||= Process.clock_gettime(Process::CLOCK_MONOTONIC) + @read_deadline

    timeout = false
    loop do
      result = @socket.read_nonblock(size, buffer, exception: false)

      return :eof if result.nil?

      remaining_time = @deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
      raise HTTP::TimeoutError, "Read timed out after #{@read_timeout} seconds" if timeout
      raise HTTP::TimeoutError, "Read timed out after a total of #{@read_deadline} seconds" if remaining_time <= 0
      return result if result != :wait_readable

      # marking the socket for timeout. Why is this not being raised immediately?
      # it seems there is some race-condition on the network level between calling
      # #read_nonblock and #wait_readable, in which #read_nonblock signalizes waiting
      # for reads, and when waiting for x seconds, it returns nil suddenly without completing
      # the x seconds. In a normal case this would be a timeout on wait/read, but it can
      # also mean that the socket has been closed by the server. Therefore we "mark" the
      # socket for timeout and try to read more bytes. If it returns :eof, it's all good, no
      # timeout. Else, the first timeout was a proper timeout.
      # This hack has to be done because io/wait#wait_readable doesn't provide a value for when
      # the socket is closed by the server, and HTTP::Parser doesn't provide the limit for the chunks.
      timeout = true unless @socket.to_io.wait_readable([remaining_time, @read_timeout].min)
    end
  end
end
