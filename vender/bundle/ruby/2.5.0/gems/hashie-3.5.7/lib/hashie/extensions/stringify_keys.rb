module Hashie
  module Extensions
    module StringifyKeys
      # Convert all keys in the hash to strings.
      #
      # @example
      #   test = {:abc => 'def'}
      #   test.stringify_keys!
      #   test # => {'abc' => 'def'}
      def stringify_keys!
        StringifyKeys.stringify_keys!(self)
        self
      end

      # Return a new hash with all keys converted
      # to strings.
      def stringify_keys
        StringifyKeys.stringify_keys(self)
      end

      module ClassMethods
        # Stringify all keys recursively within nested
        # hashes and arrays.
        # @api private
        def stringify_keys_recursively!(object)
          case object
          when self.class
            stringify_keys!(object)
          when ::Array
            object.each do |i|
              stringify_keys_recursively!(i)
            end
          when ::Hash
            stringify_keys!(object)
          end
        end

        # Convert all keys in the hash to strings.
        #
        # @param [::Hash] hash
        # @example
        #   test = {:abc => 'def'}
        #   test.stringify_keys!
        #   test # => {'abc' => 'def'}
        def stringify_keys!(hash)
          hash.extend(Hashie::Extensions::StringifyKeys) unless hash.respond_to?(:stringify_keys!)
          hash.keys.each do |k|
            stringify_keys_recursively!(hash[k])
            hash[k.to_s] = hash.delete(k)
          end
          hash
        end

        # Return a copy of hash with all keys converted
        # to strings.
        # @param [::Hash] hash
        def stringify_keys(hash)
          copy = hash.dup
          copy.extend(Hashie::Extensions::StringifyKeys) unless copy.respond_to?(:stringify_keys!)
          copy.tap do |new_hash|
            stringify_keys!(new_hash)
          end
        end
      end

      class << self
        include ClassMethods
      end
    end
  end
end
