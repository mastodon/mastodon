module Hashie
  module Extensions
    module Mash
      # Overrides the indifferent access of a Mash to keep keys in the
      # original format given to the Mash.
      #
      # @example
      #   class KeepingMash < Hashie::Mash
      #     include Hashie::Extensions::Mash::KeepOriginalKeys
      #   end
      #
      #   mash = KeepingMash.new(:symbol_key => :symbol, 'string_key' => 'string')
      #   mash.to_hash  #=> { :symbol_key => :symbol, 'string_key' => 'string' }
      #   mash['string_key'] == mash[:string_key]  #=> true
      #   mash[:symbol_key] == mash['symbol_key']  #=> true
      module KeepOriginalKeys
        private

        def self.included(descendant)
          unless descendant <= Hashie::Mash
            fail ArgumentError, "#{descendant} is not a kind of Hashie::Mash"
          end
        end

        # Converts the key when necessary to access the correct Mash key.
        #
        # @param [Object, String, Symbol] key the key to access.
        # @return [Object] the value assigned to the key.
        def convert_key(key)
          if regular_key?(key)
            key
          elsif (converted_key = __convert(key)) && regular_key?(converted_key)
            converted_key
          else
            key
          end
        end

        # Converts symbol/string keys to their alternative formats, but leaves
        # other keys alone.
        #
        # @param [Object, String, Symbol] key the key to convert.
        # @return [Object, String, Symbol] the converted key.
        def __convert(key)
          case key
          when Symbol then key.to_s
          when String then key.to_sym
          else key
          end
        end
      end
    end
  end
end
