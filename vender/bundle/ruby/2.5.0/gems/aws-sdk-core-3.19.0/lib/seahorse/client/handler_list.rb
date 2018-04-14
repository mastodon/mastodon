require 'thread'
require 'set'

module Seahorse
  module Client
    class HandlerList

      include Enumerable

      # @api private
      def initialize(options = {})
        @index = options[:index] || 0
        @entries = {}
        @mutex = Mutex.new
        entries = options[:entries] || []
        add_entries(entries) unless entries.empty?
      end

      # @return [Array<HandlerListEntry>]
      def entries
        @mutex.synchronize do
          @entries.values
        end
      end

      # Registers a handler.  Handlers are used to build a handler stack.
      # Handlers default to the `:build` step with default priority of 50.
      # The step and priority determine where in the stack a handler
      # will be.
      #
      # ## Handler Stack Ordering
      #
      # A handler stack is built from the inside-out.  The stack is
      # seeded with the send handler.  Handlers are constructed recursively
      # in reverse step and priority order so that the highest priority
      # handler is on the outside.
      #
      # By constructing the stack from the inside-out, this ensures
      # that the validate handlers will be called first and the sign handlers
      # will be called just before the final and only send handler is called.
      #
      # ## Steps
      #
      # Handlers are ordered first by step.  These steps represent the
      # life-cycle of a request.  Valid steps are:
      #
      # * `:initialize`
      # * `:validate`
      # * `:build`
      # * `:sign`
      # * `:send`
      #
      # Many handlers can be added to the same step, except for `:send`.
      # There can be only one `:send` handler.  Adding an additional
      # `:send` handler replaces the previous one.
      #
      # ## Priorities
      #
      # Handlers within a single step are executed in priority order.  The
      # higher the priority, the earlier in the stack the handler will
      # be called.
      #
      # * Handler priority is an integer between 0 and 99, inclusively.
      # * Handler priority defaults to 50.
      # * When multiple handlers are added to the same step with the same
      #   priority, the last one added will have the highest priority and
      #   the first one added will have the lowest priority.
      #
      # @param [Class<Handler>] handler_class This should be a subclass
      #   of {Handler}.
      #
      # @option options [Symbol] :step (:build) The request life-cycle
      #   step the handler should run in.  Defaults to `:build`.  The
      #   list of possible steps, in high-to-low priority order are:
      #
      #   * `:initialize`
      #   * `:validate`
      #   * `:build`
      #   * `:sign`
      #   * `:send`
      #
      #   There can only be one send handler. Registering an additional
      #   `:send` handler replaces the previous one.
      #
      # @option options [Integer] :priority (50) The priority of this
      #   handler within a step.  The priority must be between 0 and 99
      #   inclusively.  It defaults to 50.  When two handlers have the
      #   same `:step` and `:priority`, the handler registered last has
      #   the highest priority.
      #
      # @option options [Array<Symbol,String>] :operations A list of
      #   operations names the handler should be applied to.  When
      #   `:operations` is omitted, the handler is applied to all
      #   operations for the client.
      #
      # @raise [InvalidStepError]
      # @raise [InvalidPriorityError]
      # @note There can be only one `:send` handler.  Adding an additional
      #   send handler replaces the previous.
      #
      # @return [Class<Handler>] Returns the handler class that was added.
      #
      def add(handler_class, options = {})
        @mutex.synchronize do
          add_entry(
            HandlerListEntry.new(options.merge(
              handler_class: handler_class,
              inserted: next_index
            ))
          )
        end
        handler_class
      end

      # @param [Class<Handler>] handler_class
      def remove(handler_class)
        @entries.each do |key, entry|
          @entries.delete(key) if entry.handler_class == handler_class
        end
      end

      # Copies handlers from the `source_list` onto the current handler list.
      # If a block is given, only the entries that return a `true` value
      # from the block will be copied.
      # @param [HandlerList] source_list
      # @return [void]
      def copy_from(source_list, &block)
        entries = []
        source_list.entries.each do |entry|
          if block_given?
            entries << entry.copy(inserted: next_index) if yield(entry)
          else
            entries << entry.copy(inserted: next_index)
          end
        end
        add_entries(entries)
      end

      # Returns a handler list for the given operation.  The returned
      # will have the operation specific handlers merged with the common
      # handlers.
      # @param [String] operation The name of an operation.
      # @return [HandlerList]
      def for(operation)
        HandlerList.new(index: @index, entries: filter(operation.to_s))
      end

      # Yields the handlers in stack order, which is reverse priority.
      def each(&block)
        entries.sort.each do |entry|
          yield(entry.handler_class) if entry.operations.nil?
        end
      end

      # Constructs the handlers recursively, building a handler stack.
      # The `:send` handler will be at the top of the stack and the
      # `:validate` handlers will be at the bottom.
      # @return [Handler]
      def to_stack
        inject(nil) { |stack, handler| handler.new(stack) }
      end

      private

      def add_entries(entries)
        @mutex.synchronize do
          entries.each { |entry| add_entry(entry) }
        end
      end

      def add_entry(entry)
        key = entry.step == :send ? :send : entry.object_id
        @entries[key] = entry
      end

      def filter(operation)
        entries.inject([]) do |filtered, entry|
          if entry.operations.nil?
            filtered << entry.copy
          elsif entry.operations.include?(operation)
            filtered << entry.copy(operations: nil)
          end
          filtered
        end
      end

      def next_index
        @index += 1
      end

    end
  end
end
