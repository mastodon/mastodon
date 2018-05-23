require 'logger'
require 'concurrent/synchronization'

module Concurrent

  # Provides ability to add and remove handlers to be run at `Kernel#at_exit`, order is undefined.
  # Each handler is executed at most once.
  #
  # @!visibility private
  class AtExitImplementation < Synchronization::LockableObject
    include Logger::Severity

    def initialize(*args)
      super()
      synchronize { ns_initialize(*args) }
    end

    # Add a handler to be run at `Kernel#at_exit`
    # @param [Object] handler_id optionally provide an id, if allready present, handler is replaced
    # @yield the handler
    # @return id of the handler
    def add(handler_id = nil, &handler)
      id = handler_id || handler.object_id
      synchronize { @handlers[id] = handler }
      id
    end

    # Delete a handler by handler_id
    # @return [true, false]
    def delete(handler_id)
      !!synchronize { @handlers.delete handler_id }
    end

    # Is handler with handler_id rpesent?
    # @return [true, false]
    def handler?(handler_id)
      synchronize { @handlers.key? handler_id }
    end

    # @return copy of the handlers
    def handlers
      synchronize { @handlers }.clone
    end

    # install `Kernel#at_exit` callback to execute added handlers
    def install
      synchronize do
        @installed ||= begin
                         at_exit { runner }
                         true
                       end
        self
      end
    end

    # Will it run during `Kernel#at_exit`
    def enabled?
      synchronize { @enabled }
    end

    # Configure if it runs during `Kernel#at_exit`
    def enabled=(value)
      synchronize { @enabled = value }
    end

    # run the handlers manually
    # @return ids of the handlers
    def run
      handlers, _ = synchronize { handlers, @handlers = @handlers, {} }
      handlers.each do |_, handler|
        begin
          handler.call
        rescue => error
          Concurrent.global_logger.call(ERROR, error)
        end
      end
      handlers.keys
    end

    private

    def ns_initialize(enabled = true)
      @handlers = {}
      @enabled  = enabled
    end

    def runner
      run if synchronize { @enabled }
    end
  end

  private_constant :AtExitImplementation

  # @see AtExitImplementation
  # @!visibility private
  AtExit = AtExitImplementation.new.install
end
