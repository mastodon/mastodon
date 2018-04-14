module ThreadSafe
  module Util
    # A fixed size array with volatile volatile getters/setters.
    # Usage:
    #   arr = VolatileTuple.new(16)
    #   arr.volatile_set(0, :foo)
    #   arr.volatile_get(0)    # => :foo
    #   arr.cas(0, :foo, :bar) # => true
    #   arr.volatile_get(0)    # => :bar
    class VolatileTuple
      include Enumerable

      Tuple = defined?(Rubinius::Tuple) ? Rubinius::Tuple : Array

      def initialize(size)
        @tuple = tuple = Tuple.new(size)
        i = 0
        while i < size
          tuple[i] = AtomicReference.new
          i += 1
        end
      end

      def volatile_get(i)
        @tuple[i].get
      end

      def volatile_set(i, value)
        @tuple[i].set(value)
      end

      def compare_and_set(i, old_value, new_value)
        @tuple[i].compare_and_set(old_value, new_value)
      end
      alias_method :cas, :compare_and_set

      def size
        @tuple.size
      end

      def each
        @tuple.each {|ref| yield ref.get}
      end
    end
  end
end
