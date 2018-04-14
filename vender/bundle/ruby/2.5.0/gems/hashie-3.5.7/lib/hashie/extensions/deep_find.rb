module Hashie
  module Extensions
    module DeepFind
      # Performs a depth-first search on deeply nested data structures for
      # a key and returns the first occurrence of the key.
      #
      #  options = {user: {location: {address: '123 Street'}}}
      #  options.extend(Hashie::Extensions::DeepFind)
      #  options.deep_find(:address) # => '123 Street'
      #
      #  class MyHash < Hash
      #    include Hashie::Extensions::DeepFind
      #  end
      #
      #  my_hash = MyHash.new
      #  my_hash[:user] = {location: {address: '123 Street'}}
      #  my_hash.deep_find(:address) # => '123 Street'
      def deep_find(key)
        _deep_find(key)
      end

      alias_method :deep_detect, :deep_find

      # Performs a depth-first search on deeply nested data structures for
      # a key and returns all occurrences of the key.
      #
      #  options = {users: [{location: {address: '123 Street'}}, {location: {address: '234 Street'}}]}
      #  options.extend(Hashie::Extensions::DeepFind)
      #  options.deep_find_all(:address) # => ['123 Street', '234 Street']
      #
      #  class MyHash < Hash
      #    include Hashie::Extensions::DeepFind
      #  end
      #
      #  my_hash = MyHash.new
      #  my_hash[:users] = [{location: {address: '123 Street'}}, {location: {address: '234 Street'}}]
      #  my_hash.deep_find_all(:address) # => ['123 Street', '234 Street']
      def deep_find_all(key)
        matches = _deep_find_all(key)
        matches.empty? ? nil : matches
      end

      alias_method :deep_select, :deep_find_all

      private

      def _deep_find(key, object = self)
        _deep_find_all(key, object).first
      end

      def _deep_find_all(key, object = self, matches = [])
        deep_locate_result = Hashie::Extensions::DeepLocate.deep_locate(key, object).tap do |result|
          result.map! { |element| element[key] }
        end

        matches.concat(deep_locate_result)
      end
    end
  end
end
