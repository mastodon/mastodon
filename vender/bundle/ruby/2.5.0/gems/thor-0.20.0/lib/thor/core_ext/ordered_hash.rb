class Thor
  module CoreExt
    class OrderedHash < ::Hash
      if RUBY_VERSION < "1.9"
        def initialize(*args, &block)
          super
          @keys = []
        end

        def initialize_copy(other)
          super
          # make a deep copy of keys
          @keys = other.keys
        end

        def []=(key, value)
          @keys << key unless key?(key)
          super
        end

        def delete(key)
          if key? key
            index = @keys.index(key)
            @keys.delete_at index
          end
          super
        end

        def delete_if
          super
          sync_keys!
          self
        end

        alias_method :reject!, :delete_if

        def reject(&block)
          dup.reject!(&block)
        end

        def keys
          @keys.dup
        end

        def values
          @keys.map { |key| self[key] }
        end

        def to_hash
          self
        end

        def to_a
          @keys.map { |key| [key, self[key]] }
        end

        def each_key
          return to_enum(:each_key) unless block_given?
          @keys.each { |key| yield(key) }
          self
        end

        def each_value
          return to_enum(:each_value) unless block_given?
          @keys.each { |key| yield(self[key]) }
          self
        end

        def each
          return to_enum(:each) unless block_given?
          @keys.each { |key| yield([key, self[key]]) }
          self
        end

        def each_pair
          return to_enum(:each_pair) unless block_given?
          @keys.each { |key| yield(key, self[key]) }
          self
        end

        alias_method :select, :find_all

        def clear
          super
          @keys.clear
          self
        end

        def shift
          k = @keys.first
          v = delete(k)
          [k, v]
        end

        def merge!(other_hash)
          if block_given?
            other_hash.each { |k, v| self[k] = key?(k) ? yield(k, self[k], v) : v }
          else
            other_hash.each { |k, v| self[k] = v }
          end
          self
        end

        alias_method :update, :merge!

        def merge(other_hash, &block)
          dup.merge!(other_hash, &block)
        end

        # When replacing with another hash, the initial order of our keys must come from the other hash -ordered or not.
        def replace(other)
          super
          @keys = other.keys
          self
        end

        def inspect
          "#<#{self.class} #{super}>"
        end

        private

        def sync_keys!
          @keys.delete_if { |k| !key?(k) }
        end
      end
    end
  end
end
