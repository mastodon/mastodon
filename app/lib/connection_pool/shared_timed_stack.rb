# frozen_string_literal: true

class ConnectionPool::SharedTimedStack
  def initialize(max = 0, &block)
    @create_block = block
    @max          = max
    @created      = 0
    @queue        = []
    @tagged_queue = Hash.new { |hash, key| hash[key] = [] }
    @mutex        = Mutex.new
    @resource     = ConditionVariable.new
  end

  def push(connection)
    @mutex.synchronize do
      store_connection(connection)
      @resource.broadcast
    end
  end

  alias << push

  def pop(preferred_tag, timeout = 5.0)
    deadline = current_time + timeout

    @mutex.synchronize do
      loop do
        return fetch_preferred_connection(preferred_tag) unless @tagged_queue[preferred_tag].empty?

        connection = try_create(preferred_tag)
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

  def size
    @mutex.synchronize do
      @queue.size
    end
  end

  def flush
    @mutex.synchronize do
      @queue.delete_if do |connection|
        delete = !connection.in_use && (connection.dead || connection.seconds_idle >= RequestPool::MAX_IDLE_TIME)

        if delete
          @tagged_queue[connection.site].delete(connection)
          connection.close
          @created -= 1
        end

        delete
      end
    end
  end

  private

  def try_create(preferred_tag)
    if @created == @max && !@queue.empty?
      throw_away_connection = @queue.pop
      @tagged_queue[throw_away_connection.site].delete(throw_away_connection)
      throw_away_connection.close
      @create_block.call(preferred_tag)
    elsif @created != @max
      connection = @create_block.call(preferred_tag)
      @created += 1
      connection
    end
  end

  def fetch_preferred_connection(preferred_tag)
    connection = @tagged_queue[preferred_tag].pop
    @queue.delete(connection)
    connection
  end

  def current_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def store_connection(connection)
    @tagged_queue[connection.site].push(connection)
    @queue.push(connection)
  end
end
