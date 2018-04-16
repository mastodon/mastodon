module ThreadSafe
  module Test
    class Latch
      def initialize(count = 1)
        @count = count
        @mutex = Mutex.new
        @cond  = ConditionVariable.new
      end

      def release
        @mutex.synchronize do
          @count -= 1 if @count > 0
          @cond.broadcast if @count.zero?
        end
      end

      def await
        @mutex.synchronize do
          @cond.wait @mutex if @count > 0
        end
      end
    end

    class Barrier < Latch
      def await
        @mutex.synchronize do
          if @count.zero? # fall through
          elsif @count > 0
            @count -= 1
            @count.zero? ? @cond.broadcast : @cond.wait(@mutex)
          end
        end
      end
    end

    class HashCollisionKey
      attr_reader :hash, :key
      def initialize(key, hash = key.hash % 3)
        @key  = key
        @hash = hash
      end

      def eql?(other)
        other.kind_of?(self.class) && @key.eql?(other.key)
      end

      def even?
        @key.even?
      end

      def <=>(other)
        @key <=> other.key
      end
    end

    # having 4 separate HCK classes helps for a more thorough CHMV8 testing
    class HashCollisionKey2 < HashCollisionKey; end
    class HashCollisionKeyNoCompare < HashCollisionKey
      def <=>(other)
        0
      end
    end
    class HashCollisionKey4 < HashCollisionKeyNoCompare; end

    HASH_COLLISION_CLASSES = [HashCollisionKey, HashCollisionKey2, HashCollisionKeyNoCompare, HashCollisionKey4]

    def self.HashCollisionKey(key, hash = key.hash % 3)
      HASH_COLLISION_CLASSES[rand(4)].new(key, hash)
    end

    class HashCollisionKeyNonComparable < HashCollisionKey
      undef <=>
    end
  end
end
