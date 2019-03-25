# frozen_string_literal: true

require 'connection_pool'

class ConnectionPool::ManagedTimedStack < ConnectionPool::TimedStack
  def each_connection(&block)
    @mutex.synchronize do
      @que.each(&block)
    end
  end

  def delete(connection)
    @mutex.synchronize do
      @que.delete(connection)
      @created -= 1
    end
  end

  def size
    @mutex.synchronize do
      @que.size
    end
  end
end

class ManagedConnectionPool < ConnectionPool
  def initialize(options = {}, &block)
    super

    @available = ConnectionPool::ManagedTimedStack.new(@size, &block)
  end

  def each_connection(&block)
    @available.each_connection(&block)
  end

  def delete(connection)
    @available.delete(connection)
  end

  def size
    @available.size
  end

  def empty?
    size.zero?
  end
end

class RequestPool
  def self.current
    @current ||= RequestPool.new
  end

  class Reaper
    attr_reader :pool, :frequency

    def initialize(pool, frequency)
      @pool      = pool
      @frequency = frequency
    end

    def run
      return unless frequency&.positive?

      Thread.new(frequency, pool) do |t, p|
        loop do
          sleep t
          p.flush
        end
      end
    end
  end

  MAX_IDLE_TIME = 90
  WAIT_TIMEOUT  = 5
  MAX_POOL_SIZE = ENV.fetch('MAX_REQUEST_POOL_SIZE', -1).to_i

  class Connection
    attr_reader :last_used_at, :created_at, :in_use, :dead, :fresh

    def initialize(site)
      @site         = site
      @http_client  = http_client
      @last_used_at = nil
      @created_at   = current_time
      @dead         = false
      @fresh        = true
    end

    def use
      @last_used_at = current_time
      @in_use       = true

      retries = 0

      begin
        yield @http_client
      rescue HTTP::ConnectionError
        # It's possible the connection was closed, so let's
        # try re-opening it once

        close

        if @fresh || retries.positive?
          raise
        else
          @http_client = http_client
          retries     += 1
          retry
        end
      rescue StandardError
        # If this connection raises errors of any kind, it's
        # better if it gets reaped as soon as possible

        close
        @dead = true
        raise
      end
    ensure
      @fresh  = false
      @in_use = false
    end

    def seconds_idle
      current_time - (@last_used_at || @created_at)
    end

    def close
      @http_client.close
    end

    private

    def http_client
      Request.http_client.persistent(@site, timeout: MAX_IDLE_TIME)
    end

    def current_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end

  def initialize
    @pools  = Concurrent::Map.new
    @reaper = Reaper.new(self, 60)
    @reaper.run
  end

  def with(site, &block)
    connection_pool_for(site).with do |connection|
      connection.use(&block)
    end
  end

  def flush
    idle_pools = []

    @pools.each_pair do |site, pool|
      idle_connections = []

      pool.each_connection do |connection|
        next unless !connection.in_use && (connection.dead || connection.seconds_idle >= MAX_IDLE_TIME)

        connection.close
        idle_connections << connection
      end

      idle_connections.each do |connection|
        pool.delete(connection)
      end

      idle_pools << site if pool.empty?
    end

    idle_pools.each do |site|
      @pools.delete(site)
    end
  end

  def size
    @pools.values.sum(&:size)
  end

  private

  def connection_pool_for(site)
    @pools.fetch_or_store(site) do
      ManagedConnectionPool.new(size: MAX_POOL_SIZE, timeout: WAIT_TIMEOUT) { Connection.new(site) }
    end
  end
end
