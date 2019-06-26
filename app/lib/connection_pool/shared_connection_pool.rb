# frozen_string_literal: true

require 'connection_pool'
require_relative './shared_timed_stack'

class ConnectionPool::SharedConnectionPool < ConnectionPool
  def initialize(options = {}, &block)
    super(options, &block)

    @available = ConnectionPool::SharedTimedStack.new(@size, &block)
  end

  delegate :each_connection, :delete, :size, :empty?, to: :@available

  def with(preferred_tag, options = {})
    Thread.handle_interrupt(Exception => :never) do
      conn = checkout(preferred_tag, options)
      begin
        Thread.handle_interrupt(Exception => :immediate) do
          yield conn
        end
      ensure
        checkin
      end
    end
  end

  def checkout(preferred_tag, options = {})
    if ::Thread.current[@key]
      ::Thread.current[@key_count] += 1
      ::Thread.current[@key]
    else
      ::Thread.current[@key_count] = 1
      ::Thread.current[@key] = @available.pop(preferred_tag, options[:timeout] || @timeout)
    end
  end
end
