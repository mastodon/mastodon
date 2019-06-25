# frozen_string_literal: true

require 'connection_pool'
require_relative './shared_timed_stack'

class ConnectionPool::SharedConnectionPool < ConnectionPool
  def initialize(shared_size, options = {}, &block)
    super(options, &block)

    @available = ConnectionPool::SharedTimedStack.new(shared_size, @size, &block)
  end

  delegate :each_connection, :delete, :size, :empty?, to: :@available
end
