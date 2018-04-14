module Fog
  module StringifyKeys
    # Returns a new hash with all keys converted to strings.
    def self.stringify(original_hash)
      transform_hash(original_hash) do |hash, key, value|
        hash[key.to_s] = value
      end
    end

    private

    # http://devblog.avdi.org/2009/11/20/hash-transforms-in-ruby/
    def self.transform_hash(original, &block)
      original.reduce({}) do |result, (key, value)|
        block.call(result, key, value)
        result
      end
    end
  end
end
