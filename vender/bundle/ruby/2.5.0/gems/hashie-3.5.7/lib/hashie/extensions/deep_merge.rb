module Hashie
  module Extensions
    module DeepMerge
      # Returns a new hash with +self+ and +other_hash+ merged recursively.
      def deep_merge(other_hash, &block)
        copy = dup
        copy.extend(Hashie::Extensions::DeepMerge) unless copy.respond_to?(:deep_merge!)
        copy.deep_merge!(other_hash, &block)
      end

      # Returns a new hash with +self+ and +other_hash+ merged recursively.
      # Modifies the receiver in place.
      def deep_merge!(other_hash, &block)
        return self unless other_hash.is_a?(::Hash)
        _recursive_merge(self, other_hash, &block)
        self
      end

      private

      def _recursive_merge(hash, other_hash, &block)
        other_hash.each do |k, v|
          hash[k] = if hash.key?(k) && hash[k].is_a?(::Hash) && v.is_a?(::Hash)
                      _recursive_merge(hash[k], v, &block)
                    else
                      if hash.key?(k) && block_given?
                        block.call(k, hash[k], v)
                      else
                        v.respond_to?(:deep_dup) ? v.deep_dup : v
                      end
                    end
        end
        hash
      end
    end
  end
end
