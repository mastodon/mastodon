module Hashie
  module Extensions
    module Mash
      # Overrides Mash's default behavior of converting keys to strings
      #
      # @example
      #   class LazyResponse < Hashie::Mash
      #     include Hashie::Extensions::Mash::SymbolizedKeys
      #   end
      #
      #   response = LazyResponse.new("id" => 123, "name" => "Rey").to_h
      #   #=> {id: 123, name: "Rey"}
      #
      # @api public
      module SymbolizeKeys
        # Hook for being included in a class
        #
        # @api private
        # @return [void]
        # @raise [ArgumentError] when the base class isn't a Mash
        def self.included(base)
          fail ArgumentError, "#{base} must descent from Hashie::Mash" unless base <= Hashie::Mash
        end

        private

        # Converts a key to a symbol
        #
        # @api private
        # @param [String, Symbol] key the key to convert to a symbol
        # @return [void]
        def convert_key(key)
          key.to_sym
        end
      end
    end
  end
end
