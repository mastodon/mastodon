# frozen_string_literal: true

class ConnectionPool::SharedTimedStack
  def initialize(shared_size, max = 0, &block)
    @create_block = block
    @shared_size  = shared_size
    @max          = max
    @que          = []
    @mutex        = Mutex.new
    @resource     = ConditionVariable.new
  end

  def push(connection)
    @mutex.synchronize do
      @que.push(connection)
      @resource.broadcast
    end
  end

  alias << push

  def pop(timeout = 5.0)
    deadline = current_time + timeout

    @mutex.synchronize do
      loop do
        return @que.pop unless @que.empty?

        connection = try_create
        return connection if connection

        to_wait = deadline - current_time
        raise Timeout::Error, "Waited #{timeout} sec" if to_wait <= 0

        @resource.wait(@mutex, to_wait)
      end
    end
  end

  def empty?
    size.zero?
  end

  def delete(connection)
    @mutex.synchronize do
      @que.delete(connection)
      @shared_size.decrement
    end
  end

  def size
    @mutex.synchronize do
      @que.size
    end
  end

  def each_connection(&block)
    @mutex.synchronize do
      @que.each(&block)
    end
  end

  private

  def try_create
    unless @shared_size.value == @max
      object = @create_block.call
      @shared_size.increment
      object
    end
  end

  def current_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
