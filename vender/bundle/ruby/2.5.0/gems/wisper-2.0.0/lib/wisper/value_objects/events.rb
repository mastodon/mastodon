module Wisper
  module ValueObjects #:nodoc:
    # Describes allowed events
    #
    # Duck-types the argument to quack like array of strings
    # when responding to the {#include?} method call.
    class Events

      # @!scope class
      # @!method new(on)
      # Initializes a 'list' of events
      #
      # @param [NilClass, String, Symbol, Array, Regexp] list
      #
      # @raise [ArgumentError]
      #   if an argument if of unsupported type
      #
      # @return [undefined]
      def initialize(list)
        @list = list
      end

      # Check if given event is 'included' to the 'list' of events
      #
      # @param [#to_s] event
      #
      # @return [Boolean]
      def include?(event)
        appropriate_method.call(event.to_s)
      end

      private

      def methods
        {
          NilClass   => ->(_event) { true },
          String     => ->(event)  { list == event },
          Symbol     => ->(event)  { list.to_s == event },
          Enumerable => ->(event)  { list.map(&:to_s).include? event },
          Regexp     => ->(event)  { list.match(event) || false }
        }
      end

      def list
        @list
      end

      def appropriate_method
        @appropriate_method ||= methods[recognized_type]
      end

      def recognized_type
        methods.keys.detect(&list.method(:is_a?)) || type_not_recognized
      end

      def type_not_recognized
        fail(ArgumentError, "#{list.class} not supported for `on` argument")
      end
    end # class Events
  end # module ValueObjects
end # module Wisper
