require 'concurrent/constants'
require 'concurrent/thread_safe/util'
require 'concurrent/thread_safe/util/adder'
require 'concurrent/thread_safe/util/cheap_lockable'
require 'concurrent/thread_safe/util/power_of_two_tuple'
require 'concurrent/thread_safe/util/volatile'
require 'concurrent/thread_safe/util/xor_shift_random'

module Concurrent

  # @!visibility private
  module Collection

    # A Ruby port of the Doug Lea's jsr166e.ConcurrentHashMapV8 class version 1.59
    # available in public domain.
    #
    # Original source code available here:
    # http://gee.cs.oswego.edu/cgi-bin/viewcvs.cgi/jsr166/src/jsr166e/ConcurrentHashMapV8.java?revision=1.59
    #
    # The Ruby port skips out the +TreeBin+ (red-black trees for use in bins whose
    # size exceeds a threshold).
    #
    # A hash table supporting full concurrency of retrievals and high expected
    # concurrency for updates. However, even though all operations are
    # thread-safe, retrieval operations do _not_ entail locking, and there is
    # _not_ any support for locking the entire table in a way that prevents all
    # access.
    #
    # Retrieval operations generally do not block, so may overlap with update
    # operations. Retrievals reflect the results of the most recently _completed_
    # update operations holding upon their onset. (More formally, an update
    # operation for a given key bears a _happens-before_ relation with any (non
    # +nil+) retrieval for that key reporting the updated value.) For aggregate
    # operations such as +clear()+, concurrent retrievals may reflect insertion or
    # removal of only some entries. Similarly, the +each_pair+ iterator yields
    # elements reflecting the state of the hash table at some point at or since
    # the start of the +each_pair+. Bear in mind that the results of aggregate
    # status methods including +size()+ and +empty?+} are typically useful only
    # when a map is not undergoing concurrent updates in other threads. Otherwise
    # the results of these methods reflect transient states that may be adequate
    # for monitoring or estimation purposes, but not for program control.
    #
    # The table is dynamically expanded when there are too many collisions (i.e.,
    # keys that have distinct hash codes but fall into the same slot modulo the
    # table size), with the expected average effect of maintaining roughly two
    # bins per mapping (corresponding to a 0.75 load factor threshold for
    # resizing). There may be much variance around this average as mappings are
    # added and removed, but overall, this maintains a commonly accepted
    # time/space tradeoff for hash tables. However, resizing this or any other
    # kind of hash table may be a relatively slow operation. When possible, it is
    # a good idea to provide a size estimate as an optional :initial_capacity
    # initializer argument. An additional optional :load_factor constructor
    # argument provides a further means of customizing initial table capacity by
    # specifying the table density to be used in calculating the amount of space
    # to allocate for the given number of elements. Note that using many keys with
    # exactly the same +hash+ is a sure way to slow down performance of any hash
    # table.
    #
    # ## Design overview
    #
    # The primary design goal of this hash table is to maintain concurrent
    # readability (typically method +[]+, but also iteration and related methods)
    # while minimizing update contention. Secondary goals are to keep space
    # consumption about the same or better than plain +Hash+, and to support high
    # initial insertion rates on an empty table by many threads.
    #
    # Each key-value mapping is held in a +Node+. The validation-based approach
    # explained below leads to a lot of code sprawl because retry-control
    # precludes factoring into smaller methods.
    #
    # The table is lazily initialized to a power-of-two size upon the first
    # insertion. Each bin in the table normally contains a list of +Node+s (most
    # often, the list has only zero or one +Node+). Table accesses require
    # volatile/atomic reads, writes, and CASes. The lists of nodes within bins are
    # always accurately traversable under volatile reads, so long as lookups check
    # hash code and non-nullness of value before checking key equality.
    #
    # We use the top two bits of +Node+ hash fields for control purposes -- they
    # are available anyway because of addressing constraints. As explained further
    # below, these top bits are used as follows:
    #
    #   - 00 - Normal
    #   - 01 - Locked
    #   - 11 - Locked and may have a thread waiting for lock
    #   - 10 - +Node+ is a forwarding node
    #
    # The lower 28 bits of each +Node+'s hash field contain a the key's hash code,
    # except for forwarding nodes, for which the lower bits are zero (and so
    # always have hash field == +MOVED+).
    #
    # Insertion (via +[]=+ or its variants) of the first node in an empty bin is
    # performed by just CASing it to the bin. This is by far the most common case
    # for put operations under most key/hash distributions. Other update
    # operations (insert, delete, and replace) require locks. We do not want to
    # waste the space required to associate a distinct lock object with each bin,
    # so instead use the first node of a bin list itself as a lock. Blocking
    # support for these locks relies +Concurrent::ThreadSafe::Util::CheapLockable. However, we also need a
    # +try_lock+ construction, so we overlay these by using bits of the +Node+
    # hash field for lock control (see above), and so normally use builtin
    # monitors only for blocking and signalling using
    # +cheap_wait+/+cheap_broadcast+ constructions. See +Node#try_await_lock+.
    #
    # Using the first node of a list as a lock does not by itself suffice though:
    # When a node is locked, any update must first validate that it is still the
    # first node after locking it, and retry if not. Because new nodes are always
    # appended to lists, once a node is first in a bin, it remains first until
    # deleted or the bin becomes invalidated (upon resizing). However, operations
    # that only conditionally update may inspect nodes until the point of update.
    # This is a converse of sorts to the lazy locking technique described by
    # Herlihy & Shavit.
    #
    # The main disadvantage of per-bin locks is that other update operations on
    # other nodes in a bin list protected by the same lock can stall, for example
    # when user +eql?+ or mapping functions take a long time. However,
    # statistically, under random hash codes, this is not a common problem.
    # Ideally, the frequency of nodes in bins follows a Poisson distribution
    # (http://en.wikipedia.org/wiki/Poisson_distribution) with a parameter of
    # about 0.5 on average, given the resizing threshold of 0.75, although with a
    # large variance because of resizing granularity. Ignoring variance, the
    # expected occurrences of list size k are (exp(-0.5) * pow(0.5, k) /
    # factorial(k)). The first values are:
    #
    #   - 0:    0.60653066
    #   - 1:    0.30326533
    #   - 2:    0.07581633
    #   - 3:    0.01263606
    #   - 4:    0.00157952
    #   - 5:    0.00015795
    #   - 6:    0.00001316
    #   - 7:    0.00000094
    #   - 8:    0.00000006
    #   - more: less than 1 in ten million
    #
    # Lock contention probability for two threads accessing distinct elements is
    # roughly 1 / (8 * #elements) under random hashes.
    #
    # The table is resized when occupancy exceeds a percentage threshold
    # (nominally, 0.75, but see below). Only a single thread performs the resize
    # (using field +size_control+, to arrange exclusion), but the table otherwise
    # remains usable for reads and updates. Resizing proceeds by transferring
    # bins, one by one, from the table to the next table. Because we are using
    # power-of-two expansion, the elements from each bin must either stay at same
    # index, or move with a power of two offset. We eliminate unnecessary node
    # creation by catching cases where old nodes can be reused because their next
    # fields won't change. On average, only about one-sixth of them need cloning
    # when a table doubles. The nodes they replace will be garbage collectable as
    # soon as they are no longer referenced by any reader thread that may be in
    # the midst of concurrently traversing table. Upon transfer, the old table bin
    # contains only a special forwarding node (with hash field +MOVED+) that
    # contains the next table as its key. On encountering a forwarding node,
    # access and update operations restart, using the new table.
    #
    # Each bin transfer requires its bin lock. However, unlike other cases, a
    # transfer can skip a bin if it fails to acquire its lock, and revisit it
    # later. Method +rebuild+ maintains a buffer of TRANSFER_BUFFER_SIZE bins that
    # have been skipped because of failure to acquire a lock, and blocks only if
    # none are available (i.e., only very rarely). The transfer operation must
    # also ensure that all accessible bins in both the old and new table are
    # usable by any traversal. When there are no lock acquisition failures, this
    # is arranged simply by proceeding from the last bin (+table.size - 1+) up
    # towards the first. Upon seeing a forwarding node, traversals arrange to move
    # to the new table without revisiting nodes. However, when any node is skipped
    # during a transfer, all earlier table bins may have become visible, so are
    # initialized with a reverse-forwarding node back to the old table until the
    # new ones are established. (This sometimes requires transiently locking a
    # forwarding node, which is possible under the above encoding.) These more
    # expensive mechanics trigger only when necessary.
    #
    # The traversal scheme also applies to partial traversals of
    # ranges of bins (via an alternate Traverser constructor)
    # to support partitioned aggregate operations.  Also, read-only
    # operations give up if ever forwarded to a null table, which
    # provides support for shutdown-style clearing, which is also not
    # currently implemented.
    #
    # Lazy table initialization minimizes footprint until first use.
    #
    # The element count is maintained using a +Concurrent::ThreadSafe::Util::Adder+,
    # which avoids contention on updates but can encounter cache thrashing
    # if read too frequently during concurrent access. To avoid reading so
    # often, resizing is attempted either when a bin lock is
    # contended, or upon adding to a bin already holding two or more
    # nodes (checked before adding in the +x_if_absent+ methods, after
    # adding in others). Under uniform hash distributions, the
    # probability of this occurring at threshold is around 13%,
    # meaning that only about 1 in 8 puts check threshold (and after
    # resizing, many fewer do so). But this approximation has high
    # variance for small table sizes, so we check on any collision
    # for sizes <= 64. The bulk putAll operation further reduces
    # contention by only committing count updates upon these size
    # checks.
    #
    # @!visibility private
    class AtomicReferenceMapBackend

      # @!visibility private
      class Table < Concurrent::ThreadSafe::Util::PowerOfTwoTuple
        def cas_new_node(i, hash, key, value)
          cas(i, nil, Node.new(hash, key, value))
        end

        def try_to_cas_in_computed(i, hash, key)
          succeeded = false
          new_value = nil
          new_node  = Node.new(locked_hash = hash | LOCKED, key, NULL)
          if cas(i, nil, new_node)
            begin
              if NULL == (new_value = yield(NULL))
                was_null = true
              else
                new_node.value = new_value
              end
              succeeded = true
            ensure
              volatile_set(i, nil) if !succeeded || was_null
              new_node.unlock_via_hash(locked_hash, hash)
            end
          end
          return succeeded, new_value
        end

        def try_lock_via_hash(i, node, node_hash)
          node.try_lock_via_hash(node_hash) do
            yield if volatile_get(i) == node
          end
        end

        def delete_node_at(i, node, predecessor_node)
          if predecessor_node
            predecessor_node.next = node.next
          else
            volatile_set(i, node.next)
          end
        end
      end

      # Key-value entry. Nodes with a hash field of +MOVED+ are special, and do
      # not contain user keys or values. Otherwise, keys are never +nil+, and
      # +NULL+ +value+ fields indicate that a node is in the process of being
      # deleted or created. For purposes of read-only access, a key may be read
      # before a value, but can only be used after checking value to be +!= NULL+.
      #
      # @!visibility private
      class Node
        extend Concurrent::ThreadSafe::Util::Volatile
        attr_volatile :hash, :value, :next

        include Concurrent::ThreadSafe::Util::CheapLockable

        bit_shift = Concurrent::ThreadSafe::Util::FIXNUM_BIT_SIZE - 2 # need 2 bits for ourselves
        # Encodings for special uses of Node hash fields. See above for explanation.
        MOVED     = ('10' << ('0' * bit_shift)).to_i(2) # hash field for forwarding nodes
        LOCKED    = ('01' << ('0' * bit_shift)).to_i(2) # set/tested only as a bit
        WAITING   = ('11' << ('0' * bit_shift)).to_i(2) # both bits set/tested together
        HASH_BITS = ('00' << ('1' * bit_shift)).to_i(2) # usable bits of normal node hash

        SPIN_LOCK_ATTEMPTS = Concurrent::ThreadSafe::Util::CPU_COUNT > 1 ? Concurrent::ThreadSafe::Util::CPU_COUNT * 2 : 0

        attr_reader :key

        def initialize(hash, key, value, next_node = nil)
          super()
          @key = key
          self.lazy_set_hash(hash)
          self.lazy_set_value(value)
          self.next = next_node
        end

        # Spins a while if +LOCKED+ bit set and this node is the first of its bin,
        # and then sets +WAITING+ bits on hash field and blocks (once) if they are
        # still set. It is OK for this method to return even if lock is not
        # available upon exit, which enables these simple single-wait mechanics.
        #
        # The corresponding signalling operation is performed within callers: Upon
        # detecting that +WAITING+ has been set when unlocking lock (via a failed
        # CAS from non-waiting +LOCKED+ state), unlockers acquire the
        # +cheap_synchronize+ lock and perform a +cheap_broadcast+.
        def try_await_lock(table, i)
          if table && i >= 0 && i < table.size # bounds check, TODO: why are we bounds checking?
            spins = SPIN_LOCK_ATTEMPTS
            randomizer = base_randomizer = Concurrent::ThreadSafe::Util::XorShiftRandom.get
            while equal?(table.volatile_get(i)) && self.class.locked_hash?(my_hash = hash)
              if spins >= 0
                if (randomizer = (randomizer >> 1)).even? # spin at random
                  if (spins -= 1) == 0
                    Thread.pass # yield before blocking
                  else
                    randomizer = base_randomizer = Concurrent::ThreadSafe::Util::XorShiftRandom.xorshift(base_randomizer) if randomizer.zero?
                  end
                end
              elsif cas_hash(my_hash, my_hash | WAITING)
                force_aquire_lock(table, i)
                break
              end
            end
          end
        end

        def key?(key)
          @key.eql?(key)
        end

        def matches?(key, hash)
          pure_hash == hash && key?(key)
        end

        def pure_hash
          hash & HASH_BITS
        end

        def try_lock_via_hash(node_hash = hash)
          if cas_hash(node_hash, locked_hash = node_hash | LOCKED)
            begin
              yield
            ensure
              unlock_via_hash(locked_hash, node_hash)
            end
          end
        end

        def locked?
          self.class.locked_hash?(hash)
        end

        def unlock_via_hash(locked_hash, node_hash)
          unless cas_hash(locked_hash, node_hash)
            self.hash = node_hash
            cheap_synchronize { cheap_broadcast }
          end
        end

        private
        def force_aquire_lock(table, i)
          cheap_synchronize do
            if equal?(table.volatile_get(i)) && (hash & WAITING) == WAITING
              cheap_wait
            else
              cheap_broadcast # possibly won race vs signaller
            end
          end
        end

        class << self
          def locked_hash?(hash)
            (hash & LOCKED) != 0
          end
        end
      end

      # shorthands
      MOVED     = Node::MOVED
      LOCKED    = Node::LOCKED
      WAITING   = Node::WAITING
      HASH_BITS = Node::HASH_BITS

      NOW_RESIZING     = -1
      DEFAULT_CAPACITY = 16
      MAX_CAPACITY     = Concurrent::ThreadSafe::Util::MAX_INT

      # The buffer size for skipped bins during transfers. The
      # value is arbitrary but should be large enough to avoid
      # most locking stalls during resizes.
      TRANSFER_BUFFER_SIZE = 32

      extend Concurrent::ThreadSafe::Util::Volatile
      attr_volatile :table, # The array of bins. Lazily initialized upon first insertion. Size is always a power of two.

        # Table initialization and resizing control.  When negative, the
        # table is being initialized or resized. Otherwise, when table is
        # null, holds the initial table size to use upon creation, or 0
        # for default. After initialization, holds the next element count
        # value upon which to resize the table.
        :size_control

      def initialize(options = nil)
        super()
        @counter = Concurrent::ThreadSafe::Util::Adder.new
        initial_capacity  = options && options[:initial_capacity] || DEFAULT_CAPACITY
        self.size_control = (capacity = table_size_for(initial_capacity)) > MAX_CAPACITY ? MAX_CAPACITY : capacity
      end

      def get_or_default(key, else_value = nil)
        hash          = key_hash(key)
        current_table = table
        while current_table
          node = current_table.volatile_get_by_hash(hash)
          current_table =
            while node
              if (node_hash = node.hash) == MOVED
                break node.key
              elsif (node_hash & HASH_BITS) == hash && node.key?(key) && NULL != (value = node.value)
                return value
              end
              node = node.next
            end
        end
        else_value
      end

      def [](key)
        get_or_default(key)
      end

      def key?(key)
        get_or_default(key, NULL) != NULL
      end

      def []=(key, value)
        get_and_set(key, value)
        value
      end

      def compute_if_absent(key)
        hash          = key_hash(key)
        current_table = table || initialize_table
        while true
          if !(node = current_table.volatile_get(i = current_table.hash_to_index(hash)))
            succeeded, new_value = current_table.try_to_cas_in_computed(i, hash, key) { yield }
            if succeeded
              increment_size
              return new_value
            end
          elsif (node_hash = node.hash) == MOVED
            current_table = node.key
          elsif NULL != (current_value = find_value_in_node_list(node, key, hash, node_hash & HASH_BITS))
            return current_value
          elsif Node.locked_hash?(node_hash)
            try_await_lock(current_table, i, node)
          else
            succeeded, value = attempt_internal_compute_if_absent(key, hash, current_table, i, node, node_hash) { yield }
            return value if succeeded
          end
        end
      end

      def compute_if_present(key)
        new_value = nil
        internal_replace(key) do |old_value|
          if (new_value = yield(NULL == old_value ? nil : old_value)).nil?
            NULL
          else
            new_value
          end
        end
        new_value
      end

      def compute(key)
        internal_compute(key) do |old_value|
          if (new_value = yield(NULL == old_value ? nil : old_value)).nil?
            NULL
          else
            new_value
          end
        end
      end

      def merge_pair(key, value)
        internal_compute(key) do |old_value|
          if NULL == old_value || !(value = yield(old_value)).nil?
            value
          else
            NULL
          end
        end
      end

      def replace_pair(key, old_value, new_value)
        NULL != internal_replace(key, old_value) { new_value }
      end

      def replace_if_exists(key, new_value)
        if (result = internal_replace(key) { new_value }) && NULL != result
          result
        end
      end

      def get_and_set(key, value) # internalPut in the original CHMV8
        hash          = key_hash(key)
        current_table = table || initialize_table
        while true
          if !(node = current_table.volatile_get(i = current_table.hash_to_index(hash)))
            if current_table.cas_new_node(i, hash, key, value)
              increment_size
              break
            end
          elsif (node_hash = node.hash) == MOVED
            current_table = node.key
          elsif Node.locked_hash?(node_hash)
            try_await_lock(current_table, i, node)
          else
            succeeded, old_value = attempt_get_and_set(key, value, hash, current_table, i, node, node_hash)
            break old_value if succeeded
          end
        end
      end

      def delete(key)
        replace_if_exists(key, NULL)
      end

      def delete_pair(key, value)
        result = internal_replace(key, value) { NULL }
        if result && NULL != result
          !!result
        else
          false
        end
      end

      def each_pair
        return self unless current_table = table
        current_table_size = base_size = current_table.size
        i = base_index = 0
        while base_index < base_size
          if node = current_table.volatile_get(i)
            if node.hash == MOVED
              current_table      = node.key
              current_table_size = current_table.size
            else
              begin
                if NULL != (value = node.value) # skip deleted or special nodes
                  yield node.key, value
                end
              end while node = node.next
            end
          end

          if (i_with_base = i + base_size) < current_table_size
            i = i_with_base # visit upper slots if present
          else
            i = base_index += 1
          end
        end
        self
      end

      def size
        (sum = @counter.sum) < 0 ? 0 : sum # ignore transient negative values
      end

      def empty?
        size == 0
      end

      # Implementation for clear. Steps through each bin, removing all nodes.
      def clear
        return self unless current_table = table
        current_table_size = current_table.size
        deleted_count = i = 0
        while i < current_table_size
          if !(node = current_table.volatile_get(i))
            i += 1
          elsif (node_hash = node.hash) == MOVED
            current_table      = node.key
            current_table_size = current_table.size
          elsif Node.locked_hash?(node_hash)
            decrement_size(deleted_count) # opportunistically update count
            deleted_count = 0
            node.try_await_lock(current_table, i)
          else
            current_table.try_lock_via_hash(i, node, node_hash) do
              begin
                deleted_count += 1 if NULL != node.value # recheck under lock
                node.value = nil
              end while node = node.next
              current_table.volatile_set(i, nil)
              i += 1
            end
          end
        end
        decrement_size(deleted_count)
        self
      end

      private
      # Internal versions of the insertion methods, each a
      # little more complicated than the last. All have
      # the same basic structure:
      #  1. If table uninitialized, create
      #  2. If bin empty, try to CAS new node
      #  3. If bin stale, use new table
      #  4. Lock and validate; if valid, scan and add or update
      #
      # The others interweave other checks and/or alternative actions:
      #  * Plain +get_and_set+ checks for and performs resize after insertion.
      #  * compute_if_absent prescans for mapping without lock (and fails to add
      #    if present), which also makes pre-emptive resize checks worthwhile.
      #
      # Someday when details settle down a bit more, it might be worth
      # some factoring to reduce sprawl.
      def internal_replace(key, expected_old_value = NULL, &block)
        hash          = key_hash(key)
        current_table = table
        while current_table
          if !(node = current_table.volatile_get(i = current_table.hash_to_index(hash)))
            break
          elsif (node_hash = node.hash) == MOVED
            current_table = node.key
          elsif (node_hash & HASH_BITS) != hash && !node.next # precheck
            break # rules out possible existence
          elsif Node.locked_hash?(node_hash)
            try_await_lock(current_table, i, node)
          else
            succeeded, old_value = attempt_internal_replace(key, expected_old_value, hash, current_table, i, node, node_hash, &block)
            return old_value if succeeded
          end
        end
        NULL
      end

      def attempt_internal_replace(key, expected_old_value, hash, current_table, i, node, node_hash)
        current_table.try_lock_via_hash(i, node, node_hash) do
          predecessor_node = nil
          old_value        = NULL
          begin
            if node.matches?(key, hash) && NULL != (current_value = node.value)
              if NULL == expected_old_value || expected_old_value == current_value # NULL == expected_old_value means whatever value
                old_value = current_value
                if NULL == (node.value = yield(old_value))
                  current_table.delete_node_at(i, node, predecessor_node)
                  decrement_size
                end
              end
              break
            end

            predecessor_node = node
          end while node = node.next

          return true, old_value
        end
      end

      def find_value_in_node_list(node, key, hash, pure_hash)
        do_check_for_resize = false
        while true
          if pure_hash == hash && node.key?(key) && NULL != (value = node.value)
            return value
          elsif node = node.next
            do_check_for_resize = true # at least 2 nodes -> check for resize
            pure_hash = node.pure_hash
          else
            return NULL
          end
        end
      ensure
        check_for_resize if do_check_for_resize
      end

      def internal_compute(key, &block)
        hash          = key_hash(key)
        current_table = table || initialize_table
        while true
          if !(node = current_table.volatile_get(i = current_table.hash_to_index(hash)))
            succeeded, new_value = current_table.try_to_cas_in_computed(i, hash, key, &block)
            if succeeded
              if NULL == new_value
                break nil
              else
                increment_size
                break new_value
              end
            end
          elsif (node_hash = node.hash) == MOVED
            current_table = node.key
          elsif Node.locked_hash?(node_hash)
            try_await_lock(current_table, i, node)
          else
            succeeded, new_value = attempt_compute(key, hash, current_table, i, node, node_hash, &block)
            break new_value if succeeded
          end
        end
      end

      def attempt_internal_compute_if_absent(key, hash, current_table, i, node, node_hash)
        added = false
        current_table.try_lock_via_hash(i, node, node_hash) do
          while true
            if node.matches?(key, hash) && NULL != (value = node.value)
              return true, value
            end
            last = node
            unless node = node.next
              last.next = Node.new(hash, key, value = yield)
              added = true
              increment_size
              return true, value
            end
          end
        end
      ensure
        check_for_resize if added
      end

      def attempt_compute(key, hash, current_table, i, node, node_hash)
        added = false
        current_table.try_lock_via_hash(i, node, node_hash) do
          predecessor_node = nil
          while true
            if node.matches?(key, hash) && NULL != (value = node.value)
              if NULL == (node.value = value = yield(value))
                current_table.delete_node_at(i, node, predecessor_node)
                decrement_size
                value = nil
              end
              return true, value
            end
            predecessor_node = node
            unless node = node.next
              if NULL == (value = yield(NULL))
                value = nil
              else
                predecessor_node.next = Node.new(hash, key, value)
                added = true
                increment_size
              end
              return true, value
            end
          end
        end
      ensure
        check_for_resize if added
      end

      def attempt_get_and_set(key, value, hash, current_table, i, node, node_hash)
        node_nesting = nil
        current_table.try_lock_via_hash(i, node, node_hash) do
          node_nesting    = 1
          old_value       = nil
          found_old_value = false
          while node
            if node.matches?(key, hash) && NULL != (old_value = node.value)
              found_old_value = true
              node.value = value
              break
            end
            last = node
            unless node = node.next
              last.next = Node.new(hash, key, value)
              break
            end
            node_nesting += 1
          end

          return true, old_value if found_old_value
          increment_size
          true
        end
      ensure
        check_for_resize if node_nesting && (node_nesting > 1 || current_table.size <= 64)
      end

      def initialize_copy(other)
        super
        @counter = Concurrent::ThreadSafe::Util::Adder.new
        self.table = nil
        self.size_control = (other_table = other.table) ? other_table.size : DEFAULT_CAPACITY
        self
      end

      def try_await_lock(current_table, i, node)
        check_for_resize # try resizing if can't get lock
        node.try_await_lock(current_table, i)
      end

      def key_hash(key)
        key.hash & HASH_BITS
      end

      # Returns a power of two table size for the given desired capacity.
      def table_size_for(entry_count)
        size = 2
        size <<= 1 while size < entry_count
        size
      end

      # Initializes table, using the size recorded in +size_control+.
      def initialize_table
        until current_table ||= table
          if (size_ctrl = size_control) == NOW_RESIZING
            Thread.pass # lost initialization race; just spin
          else
            try_in_resize_lock(current_table, size_ctrl) do
              initial_size = size_ctrl > 0 ? size_ctrl : DEFAULT_CAPACITY
              current_table = self.table = Table.new(initial_size)
              initial_size - (initial_size >> 2) # 75% load factor
            end
          end
        end
        current_table
      end

      # If table is too small and not already resizing, creates next table and
      # transfers bins. Rechecks occupancy after a transfer to see if another
      # resize is already needed because resizings are lagging additions.
      def check_for_resize
        while (current_table = table) && MAX_CAPACITY > (table_size = current_table.size) && NOW_RESIZING != (size_ctrl = size_control) && size_ctrl < @counter.sum
          try_in_resize_lock(current_table, size_ctrl) do
            self.table = rebuild(current_table)
            (table_size << 1) - (table_size >> 1) # 75% load factor
          end
        end
      end

      def try_in_resize_lock(current_table, size_ctrl)
        if cas_size_control(size_ctrl, NOW_RESIZING)
          begin
            if current_table == table # recheck under lock
              size_ctrl = yield # get new size_control
            end
          ensure
            self.size_control = size_ctrl
          end
        end
      end

      # Moves and/or copies the nodes in each bin to new table. See above for explanation.
      def rebuild(table)
        old_table_size = table.size
        new_table      = table.next_in_size_table
        # puts "#{old_table_size} -> #{new_table.size}"
        forwarder      = Node.new(MOVED, new_table, NULL)
        rev_forwarder  = nil
        locked_indexes = nil # holds bins to revisit; nil until needed
        locked_arr_idx = 0
        bin            = old_table_size - 1
        i              = bin
        while true
          if !(node = table.volatile_get(i))
            # no lock needed (or available) if bin >= 0, because we're not popping values from locked_indexes until we've run through the whole table
            redo unless (bin >= 0 ? table.cas(i, nil, forwarder) : lock_and_clean_up_reverse_forwarders(table, old_table_size, new_table, i, forwarder))
          elsif Node.locked_hash?(node_hash = node.hash)
            locked_indexes ||= Array.new
            if bin < 0 && locked_arr_idx > 0
              locked_arr_idx -= 1
              i, locked_indexes[locked_arr_idx] = locked_indexes[locked_arr_idx], i # swap with another bin
              redo
            end
            if bin < 0 || locked_indexes.size >= TRANSFER_BUFFER_SIZE
              node.try_await_lock(table, i) # no other options -- block
              redo
            end
            rev_forwarder ||= Node.new(MOVED, table, NULL)
            redo unless table.volatile_get(i) == node && node.locked? # recheck before adding to list
            locked_indexes << i
            new_table.volatile_set(i, rev_forwarder)
            new_table.volatile_set(i + old_table_size, rev_forwarder)
          else
            redo unless split_old_bin(table, new_table, i, node, node_hash, forwarder)
          end

          if bin > 0
            i = (bin -= 1)
          elsif locked_indexes && !locked_indexes.empty?
            bin = -1
            i = locked_indexes.pop
            locked_arr_idx = locked_indexes.size - 1
          else
            return new_table
          end
        end
      end

      def lock_and_clean_up_reverse_forwarders(old_table, old_table_size, new_table, i, forwarder)
        # transiently use a locked forwarding node
        locked_forwarder = Node.new(moved_locked_hash = MOVED | LOCKED, new_table, NULL)
        if old_table.cas(i, nil, locked_forwarder)
          new_table.volatile_set(i, nil) # kill the potential reverse forwarders
          new_table.volatile_set(i + old_table_size, nil) # kill the potential reverse forwarders
          old_table.volatile_set(i, forwarder)
          locked_forwarder.unlock_via_hash(moved_locked_hash, MOVED)
          true
        end
      end

      # Splits a normal bin with list headed by e into lo and hi parts; installs in given table.
      def split_old_bin(table, new_table, i, node, node_hash, forwarder)
        table.try_lock_via_hash(i, node, node_hash) do
          split_bin(new_table, i, node, node_hash)
          table.volatile_set(i, forwarder)
        end
      end

      def split_bin(new_table, i, node, node_hash)
        bit          = new_table.size >> 1 # bit to split on
        run_bit      = node_hash & bit
        last_run     = nil
        low          = nil
        high         = nil
        current_node = node
        # this optimises for the lowest amount of volatile writes and objects created
        while current_node = current_node.next
          unless (b = current_node.hash & bit) == run_bit
            run_bit  = b
            last_run = current_node
          end
        end
        if run_bit == 0
          low = last_run
        else
          high = last_run
        end
        current_node = node
        until current_node == last_run
          pure_hash = current_node.pure_hash
          if (pure_hash & bit) == 0
            low = Node.new(pure_hash, current_node.key, current_node.value, low)
          else
            high = Node.new(pure_hash, current_node.key, current_node.value, high)
          end
          current_node = current_node.next
        end
        new_table.volatile_set(i, low)
        new_table.volatile_set(i + bit, high)
      end

      def increment_size
        @counter.increment
      end

      def decrement_size(by = 1)
        @counter.add(-by)
      end
    end
  end
end
