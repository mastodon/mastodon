module Seahorse
  module Client

    # A container for an un-constructed handler. A handler entry has the
    # handler class, and information about handler priority/order.
    #
    # This class is an implementation detail of the {HandlerList} class.
    # Do not rely on public interfaces of this class.
    class HandlerListEntry

      STEPS = {
        initialize: 400,
        validate: 300,
        build: 200,
        sign: 100,
        send: 0,
      }

      # @option options [required, Class<Handler>] :handler_class
      # @option options [required, Integer] :inserted The insertion
      #   order/position. This is used to determine sort order when two
      #   entries have the same priority.
      # @option options [Symbol] :step (:build)
      # @option options [Integer] :priority (50)
      # @option options [Set<String>] :operations
      def initialize(options)
        @options = options
        @handler_class = option(:handler_class, options)
        @inserted = option(:inserted, options)
        @operations = options[:operations]
        @operations = Set.new(options[:operations]).map(&:to_s) if @operations
        set_step(options[:step] || :build)
        set_priority(options[:priority] || 50)
        compute_weight
      end

      # @return [Handler, Class<Handler>] Returns the handler.  This may
      #   be a constructed handler object or a handler class.
      attr_reader :handler_class

      # @return [Integer] The insertion order/position.  This is used to
      #   determine sort order when two entries have the same priority.
      #   Entries inserted later (with a higher inserted value) have a
      #   lower priority.
      attr_reader :inserted

      # @return [Symbol]
      attr_reader :step

      # @return [Integer]
      attr_reader :priority

      # @return [Set<String>]
      attr_reader :operations

      # @return [Integer]
      attr_reader :weight

      # @api private
      def <=>(other)
        if weight == other.weight
          other.inserted <=> inserted
        else
          weight <=> other.weight
        end
      end

      # @option options (see #initialize)
      # @return [HandlerListEntry]
      def copy(options = {})
        HandlerListEntry.new(@options.merge(options))
      end

      private

      def option(name, options)
        if options.key?(name)
          options[name]
        else
          msg = "invalid :priority `%s', must be between 0 and 99"
          raise ArgumentError, msg % priority.inspect
        end
      end

      def set_step(step)
        if STEPS.key?(step)
          @step = step
        else
          msg = "invalid :step `%s', must be one of :initialize, :validate, "
          msg << ":build, :sign or :send"
          raise ArgumentError, msg % step.inspect
        end
      end

      def set_priority(priority)
        if (0..99).include?(priority)
          @priority = priority
        else
          msg = "invalid :priority `%s', must be between 0 and 99"
          raise ArgumentError, msg % priority.inspect
        end
      end

      def compute_weight
        @weight = STEPS[@step] + @priority
      end

    end
  end
end
