module Wisper
  module ValueObjects #:nodoc:
    # Prefix for notifications
    #
    # @example
    #   Wisper::ValueObjects::Prefix.new nil    # => ""
    #   Wisper::ValueObjects::Prefix.new "when" # => "when_"
    #   Wisper::ValueObjects::Prefix.new true   # => "on_"
    class Prefix < String
      class << self
        attr_accessor :default
      end

      # @param [true, nil, #to_s] value
      #
      # @return [undefined]
      def initialize(value = nil)
        super "#{ (value == true) ? default : value }_"
        replace "" if self == "_"
      end

      private

      def default
        self.class.default || 'on'
      end
    end # class Prefix
  end # module ValueObjects
end # module Wisper
