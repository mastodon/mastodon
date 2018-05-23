require "hamster/immutable"
require "hamster/enumerable"

module Hamster

  # A `SortedSet` is a collection of ordered values with no duplicates. Unlike a
  # {Vector}, in which items can appear in any arbitrary order, a `SortedSet` always
  # keeps items either in their natural order, or in an order defined by a comparator
  # block which is provided at initialization time.
  #
  # `SortedSet` uses `#<=>` (or its comparator block) to determine which items are
  # equivalent. If the comparator indicates that an existing item and a new item are
  # equal, any attempt to insert the new item will have no effect.
  #
  # This means that *all* the items inserted into any one `SortedSet` must all be
  # comparable. For example, you cannot put `String`s and `Integer`s in the same
  # `SortedSet`. This is unlike {Set}, which can store items of any type, as long
  # as they all support `#hash` and `#eql?`.
  #
  # A `SortedSet` can be created in either of the following ways:
  #
  #     Hamster::SortedSet.new([1, 2, 3]) # any Enumerable can be used to initialize
  #     Hamster::SortedSet['A', 'B', 'C', 'D']
  #
  # Or if you want to use a custom ordering:
  #
  #     Hamster::SortedSet.new([1,2,3]) { |a, b| -a <=> -b }
  #     Hamster::SortedSet.new([1, 2, 3]) { |num| -num }
  #
  # `SortedSet` can use a 2-parameter block which returns 0, 1, or -1
  # as a comparator (like `Array#sort`), *or* use a 1-parameter block to derive sort
  # keys (like `Array#sort_by`) which will be compared using `#<=>`.
  #
  # Like all Hamster collections, `SortedSet`s are immutable. Any operation which you
  # might expect to "modify" a `SortedSet` will actually return a new collection and
  # leave the existing one unchanged.
  #
  # `SortedSet` supports the same basic set-theoretic operations as {Set}, including
  # {#union}, {#intersection}, {#difference}, and {#exclusion}, as well as {#subset?},
  # {#superset?}, and so on. Unlike {Set}, it does not define comparison operators like
  # `#>` or `#<` as aliases for the superset/subset predicates. Instead, these comparison
  # operators do a item-by-item comparison between the `SortedSet` and another sequential
  # collection. (See `Array#<=>` for details.)
  #
  # Additionally, since `SortedSet`s are ordered, they also support indexed retrieval
  # of items using {#at} or {#[]}. Like {Vector},
  # negative indices count back from the end of the `SortedSet`.
  #
  # Getting the {#max} or {#min} item from a `SortedSet`, as defined by its comparator,
  # is a constant time operation.
  #
  class SortedSet
    include Immutable
    include Enumerable

    class << self
      # Create a new `SortedSet` populated with the given items. This method does not
      # accept a comparator block.
      #
      # @return [SortedSet]
      def [](*items)
        new(items)
      end

      # Return an empty `SortedSet`. If used on a subclass, returns an empty instance
      # of that class.
      #
      # @return [SortedSet]
      def empty
        @empty ||= self.alloc(PlainAVLNode::EmptyNode)
      end

      # "Raw" allocation of a new `SortedSet`. Used internally to create a new
      # instance quickly after obtaining a modified binary tree.
      #
      # @return [Set]
      # @private
      def alloc(node)
        result = allocate
        result.instance_variable_set(:@node, node)
        result
      end
    end

    def initialize(items=[], &block)
      items = items.to_a
      if block
        if block.arity == 1 || block.arity == -1
          comparator = lambda { |a,b| block.call(a) <=> block.call(b) }
          items = items.sort_by(&block)
        else
          comparator = block
          items = items.sort(&block)
        end
        @node = AVLNode.from_items(items, comparator)
      else
        @node = PlainAVLNode.from_items(items.sort)
      end
    end

    # Return `true` if this `SortedSet` contains no items.
    #
    # @return [Boolean]
    def empty?
      @node.empty?
    end

    # Return the number of items in this `SortedSet`.
    #
    # @example
    #   Hamster::SortedSet["A", "B", "C"].size  # => 3
    #
    # @return [Integer]
    def size
      @node.size
    end
    alias :length :size

    # Return a new `SortedSet` with `item` added. If `item` is already in the set,
    # return `self`.
    #
    # @example
    #   Hamster::SortedSet["Dog", "Lion"].add("Elephant")
    #   # => Hamster::SortedSet["Dog", "Elephant", "Lion"]
    #
    # @param item [Object] The object to add
    # @return [SortedSet]
    def add(item)
      catch :present do
        node = @node.insert(item)
        return self.class.alloc(node)
      end
      self
    end
    alias :<< :add

    # If `item` is not a member of this `SortedSet`, return a new `SortedSet` with
    # `item` added. Otherwise, return `false`.
    #
    # @example
    #   Hamster::SortedSet["Dog", "Lion"].add?("Elephant")
    #   # => Hamster::SortedSet["Dog", "Elephant", "Lion"]
    #   Hamster::SortedSet["Dog", "Lion"].add?("Lion")
    #   # => false
    #
    # @param item [Object] The object to add
    # @return [SortedSet, false]
    def add?(item)
      !include?(item) && add(item)
    end

    # Return a new `SortedSet` with `item` removed. If `item` is not a member of the set,
    # return `self`.
    #
    # @example
    #   Hamster::SortedSet["A", "B", "C"].delete("B")
    #   # => Hamster::SortedSet["A", "C"]
    #
    # @param item [Object] The object to remove
    # @return [SortedSet]
    def delete(item)
      catch :not_present do
        node = @node.delete(item)
        if node.empty? && node.natural_order?
          return self.class.empty
        else
          return self.class.alloc(node)
        end
      end
      self
    end

    # If `item` is a member of this `SortedSet`, return a new `SortedSet` with
    # `item` removed. Otherwise, return `false`.
    #
    # @example
    #   Hamster::SortedSet["A", "B", "C"].delete?("B")
    #   # => Hamster::SortedSet["A", "C"]
    #   Hamster::SortedSet["A", "B", "C"].delete?("Z")
    #   # => false
    #
    # @param item [Object] The object to remove
    # @return [SortedSet, false]
    def delete?(item)
      include?(item) && delete(item)
    end

    # Return a new `SortedSet` with the item at `index` removed. If the given `index`
    # does not exist (if it is too high or too low), return `self`.
    #
    # @example
    #   Hamster::SortedSet["A", "B", "C", "D"].delete_at(2)
    #   # => Hamster::SortedSet["A", "B", "D"]
    #
    # @param index [Integer] The index to remove
    # @return [SortedSet]
    def delete_at(index)
      (item = at(index)) ? delete(item) : self
    end

    # Retrieve the item at `index`. If there is none (either the provided index
    # is too high or too low), return `nil`.
    #
    # @example
    #   s = Hamster::SortedSet["A", "B", "C", "D", "E", "F"]
    #   s.at(2)   # => "C"
    #   s.at(-2)  # => "E"
    #   s.at(6)   # => nil
    #
    # @param index [Integer] The index to retrieve
    # @return [Object]
    def at(index)
      index += @node.size if index < 0
      return nil if index >= @node.size || index < 0
      @node.at(index)
    end

    # Retrieve the value at `index` with optional default.
    #
    # @overload fetch(index)
    #   Retrieve the value at the given index, or raise an `IndexError` if not
    #   found.
    #
    #   @param index [Integer] The index to look up
    #   @raise [IndexError] if index does not exist
    #   @example
    #     v = Hamster::SortedSet["A", "B", "C", "D"]
    #     v.fetch(2)       # => "C"
    #     v.fetch(-1)      # => "D"
    #     v.fetch(4)       # => IndexError: index 4 outside of vector bounds
    #
    # @overload fetch(index) { |index| ... }
    #   Retrieve the value at the given index, or return the result of yielding
    #   the block if not found.
    #
    #   @yield Once if the index is not found.
    #   @yieldparam [Integer] index The index which does not exist
    #   @yieldreturn [Object] Default value to return
    #   @param index [Integer] The index to look up
    #   @example
    #     v = Hamster::SortedSet["A", "B", "C", "D"]
    #     v.fetch(2) { |i| i * i }   # => "C"
    #     v.fetch(4) { |i| i * i }   # => 16
    #
    # @overload fetch(index, default)
    #   Retrieve the value at the given index, or return the provided `default`
    #   value if not found.
    #
    #   @param index [Integer] The index to look up
    #   @param default [Object] Object to return if the key is not found
    #   @example
    #     v = Hamster::SortedSet["A", "B", "C", "D"]
    #     v.fetch(2, "Z")  # => "C"
    #     v.fetch(4, "Z")  # => "Z"
    #
    # @return [Object]
    def fetch(index, default = (missing_default = true))
      if index >= -@node.size && index < @node.size
        at(index)
      elsif block_given?
        yield(index)
      elsif !missing_default
        default
      else
        raise IndexError, "index #{index} outside of sorted set bounds"
      end
    end

    # Return specific objects from the `Vector`. All overloads return `nil` if
    # the starting index is out of range.
    #
    # @overload set.slice(index)
    #   Returns a single object at the given `index`. If `index` is negative,
    #   count backwards from the end.
    #
    #   @param index [Integer] The index to retrieve. May be negative.
    #   @return [Object]
    #   @example
    #     s = Hamster::SortedSet["A", "B", "C", "D", "E", "F"]
    #     s[2]  # => "C"
    #     s[-1] # => "F"
    #     s[6]  # => nil
    #
    # @overload set.slice(index, length)
    #   Return a subset starting at `index` and continuing for `length`
    #   elements or until the end of the `SortedSet`, whichever occurs first.
    #
    #   @param start [Integer] The index to start retrieving items from. May be
    #                          negative.
    #   @param length [Integer] The number of items to retrieve.
    #   @return [SortedSet]
    #   @example
    #     s = Hamster::SortedSet["A", "B", "C", "D", "E", "F"]
    #     s[2, 3]  # => Hamster::SortedSet["C", "D", "E"]
    #     s[-2, 3] # => Hamster::SortedSet["E", "F"]
    #     s[20, 1] # => nil
    #
    # @overload set.slice(index..end)
    #   Return a subset starting at `index` and continuing to index
    #   `end` or the end of the `SortedSet`, whichever occurs first.
    #
    #   @param range [Range] The range of indices to retrieve.
    #   @return [SortedSet]
    #   @example
    #     s = Hamster::SortedSet["A", "B", "C", "D", "E", "F"]
    #     s[2..3]    # => Hamster::SortedSet["C", "D"]
    #     s[-2..100] # => Hamster::SortedSet["E", "F"]
    #     s[20..21]  # => nil
    def slice(arg, length = (missing_length = true))
      if missing_length
        if arg.is_a?(Range)
          from, to = arg.begin, arg.end
          from += @node.size if from < 0
          to   += @node.size if to < 0
          to   += 1     if !arg.exclude_end?
          length = to - from
          length = 0 if length < 0
          subsequence(from, length)
        else
          at(arg)
        end
      else
        arg += @node.size if arg < 0
        subsequence(arg, length)
      end
    end
    alias :[] :slice

    # Return a new `SortedSet` with only the elements at the given `indices`.
    # If any of the `indices` do not exist, they will be skipped.
    #
    # @example
    #   s = Hamster::SortedSet["A", "B", "C", "D", "E", "F"]
    #   s.values_at(2, 4, 5)   # => Hamster::SortedSet["C", "E", "F"]
    #
    # @param indices [Array] The indices to retrieve and gather into a new `SortedSet`
    # @return [SortedSet]
    def values_at(*indices)
      indices.select! { |i| i >= -@node.size && i < @node.size }
      self.class.new(indices.map! { |i| at(i) })
    end

    # Call the given block once for each item in the set, passing each
    # item from first to last successively to the block. If no block is
    # provided, returns an `Enumerator`.
    #
    # @example
    #   Hamster::SortedSet["A", "B", "C"].each { |e| puts "Element: #{e}" }
    #
    #   Element: A
    #   Element: B
    #   Element: C
    #   # => Hamster::SortedSet["A", "B", "C"]
    #
    # @yield [item]
    # @return [self, Enumerator]
    def each(&block)
      return @node.to_enum if not block_given?
      @node.each(&block)
      self
    end

    # Call the given block once for each item in the set, passing each
    # item starting from the last, and counting back to the first, successively to
    # the block.
    #
    # @example
    #   Hamster::SortedSet["A", "B", "C"].reverse_each { |e| puts "Element: #{e}" }
    #
    #   Element: C
    #   Element: B
    #   Element: A
    #   # => Hamster::SortedSet["A", "B", "C"]
    #
    # @return [self]
    def reverse_each(&block)
      return @node.enum_for(:reverse_each) if not block_given?
      @node.reverse_each(&block)
      self
    end

    # Return the "lowest" element in this set, as determined by its sort order.
    # Or, if a block is provided, use the block as a comparator to find the
    # "lowest" element. (See `Enumerable#min`.)
    #
    # @example
    #   Hamster::SortedSet["A", "B", "C"].min  # => "A"
    #
    # @return [Object]
    # @yield [a, b] Any number of times with different pairs of elements.
    def min
      block_given? ? super : @node.min
    end

    # Return the "lowest" element in this set, as determined by its sort order.
    # @return [Object]
    def first
      @node.min
    end

    # Return the "highest" element in this set, as determined by its sort order.
    # Or, if a block is provided, use the block as a comparator to find the
    # "highest" element. (See `Enumerable#max`.)
    #
    # @example
    #   Hamster::SortedSet["A", "B", "C"].max  # => "C"
    #
    # @yield [a, b] Any number of times with different pairs of elements.
    # @return [Object]
    def max
      block_given? ? super : @node.max
    end

    # Return the "highest" element in this set, as determined by its sort order.
    # @return [Object]
    def last
      @node.max
    end

    # Return a new `SortedSet` containing all elements for which the given block returns
    # true.
    #
    # @example
    #   Hamster::SortedSet["Bird", "Cow", "Elephant"].select { |e| e.size >= 4 }
    #   # => Hamster::SortedSet["Bird", "Elephant"]
    #
    # @return [SortedSet]
    # @yield [item] Once for each item.
    def select
      return enum_for(:select) unless block_given?
      items_to_delete = []
      each { |item| items_to_delete << item unless yield(item) }
      derive_new_sorted_set(@node.bulk_delete(items_to_delete))
    end
    alias :find_all :select
    alias :keep_if  :select

    # Invoke the given block once for each item in the set, and return a new
    # `SortedSet` containing the values returned by the block. If no block is
    # given, returns an `Enumerator`.
    #
    # @example
    #   Hamster::SortedSet[1, 2, 3].map { |e| -(e * e) }
    #   # => Hamster::SortedSet[-9, -4, -1]
    #
    # @return [SortedSet, Enumerator]
    # @yield [item] Once for each item.
    def map
      return enum_for(:map) if not block_given?
      return self if empty?
      self.class.alloc(@node.from_items(super))
    end
    alias :collect :map

    # Return `true` if the given item is present in this `SortedSet`. More precisely,
    # return `true` if an object which compares as "equal" using this set's
    # comparator is present.
    #
    # @example
    #   Hamster::SortedSet["A", "B", "C"].include?("B")  # => true
    #
    # @param item [Object] The object to check for
    # @return [Boolean]
    def include?(item)
      @node.include?(item)
    end
    alias :member? :include?

    # Return a new `SortedSet` with the same items, but a sort order determined
    # by the given block.
    #
    # @example
    #   Hamster::SortedSet["Bird", "Cow", "Elephant"].sort { |a, b| a.size <=> b.size }
    #   # => Hamster::SortedSet["Cow", "Bird", "Elephant"]
    #   Hamster::SortedSet["Bird", "Cow", "Elephant"].sort_by { |e| e.size }
    #   # => Hamster::SortedSet["Cow", "Bird", "Elephant"]
    #
    # @return [SortedSet]
    def sort(&block)
      if block
        self.class.new(self.to_a, &block)
      else
        self.class.new(self.to_a.sort)
      end      
    end
    alias :sort_by :sort

    # Find the index of a given object or an element that satisfies the given
    # block.
    #
    # @overload find_index(obj)
    #   Return the index of the first object in this set which is equal to
    #   `obj`. Rather than using `#==`, we use `#<=>` (or our comparator block)
    #   for comparisons. This means we can find the index in `O(log N)` time,
    #   rather than `O(N)`.
    #   @param obj [Object] The object to search for
    #   @example
    #     s = Hamster::SortedSet[2, 4, 6, 8, 10]
    #     s.find_index(8)  # => 3
    # @overload find_index
    #   Return the index of the first object in this sorted set for which the
    #   block returns to true. This takes `O(N)` time.
    #   @yield [element] An element in the sorted set
    #   @yieldreturn [Boolean] True if this is element matches
    #   @example
    #     s = Hamster::SortedSet[2, 4, 6, 8, 10]
    #     s.find_index { |e| e > 7 }  # => 3
    #
    # @return [Integer] The index of the object, or `nil` if not found.
    def find_index(obj = (missing_obj = true), &block)
      if !missing_obj
        # Enumerable provides a default implementation, but this is more efficient
        node = @node
        index = node.left.size
        while !node.empty?
          direction = node.direction(obj)
          if direction > 0
            node = node.right
            index += (node.left.size + 1)
          elsif direction < 0
            node = node.left
            index -= (node.right.size + 1)
          else
            return index
          end
        end
        nil
      else
        super(&block)
      end
    end
    alias :index :find_index

    # Drop the first `n` elements and return the rest in a new `SortedSet`.
    #
    # @example
    #   Hamster::SortedSet["A", "B", "C", "D", "E", "F"].drop(2)
    #   # => Hamster::SortedSet["C", "D", "E", "F"]
    #
    # @param n [Integer] The number of elements to remove
    # @return [SortedSet]
    def drop(n)
      derive_new_sorted_set(@node.drop(n))
    end

    # Return only the first `n` elements in a new `SortedSet`.
    #
    # @example
    #   Hamster::SortedSet["A", "B", "C", "D", "E", "F"].take(4)
    #   # => Hamster::SortedSet["A", "B", "C", "D"]
    #
    # @param n [Integer] The number of elements to retain
    # @return [SortedSet]
    def take(n)
      derive_new_sorted_set(@node.take(n))
    end

    # Drop elements up to, but not including, the first element for which the
    # block returns `nil` or `false`. Gather the remaining elements into a new
    # `SortedSet`. If no block is given, an `Enumerator` is returned instead.
    #
    # @example
    #   Hamster::SortedSet[2, 4, 6, 7, 8, 9].drop_while { |e| e.even? }
    #   # => Hamster::SortedSet[7, 8, 9]
    #
    # @yield [item]
    # @return [SortedSet, Enumerator]
    def drop_while
      return enum_for(:drop_while) if not block_given?
      n = 0
      each do |item|
        break unless yield item
        n += 1
      end
      drop(n)
    end

    # Gather elements up to, but not including, the first element for which the
    # block returns `nil` or `false`, and return them in a new `SortedSet`. If no block
    # is given, an `Enumerator` is returned instead.
    #
    # @example
    #   Hamster::SortedSet[2, 4, 6, 7, 8, 9].take_while { |e| e.even? }
    #   # => Hamster::SortedSet[2, 4, 6]
    #
    # @return [SortedSet, Enumerator]
    # @yield [item]
    def take_while
      return enum_for(:take_while) if not block_given?
      n = 0
      each do |item|
        break unless yield item
        n += 1
      end
      take(n)
    end

    # Return a new `SortedSet` which contains all the members of both this set and `other`.
    # `other` can be any `Enumerable` object.
    #
    # @example
    #   Hamster::SortedSet[1, 2] | Hamster::SortedSet[2, 3]
    #   # => Hamster::SortedSet[1, 2, 3]
    #
    # @param other [Enumerable] The collection to merge with
    # @return [SortedSet]
    def union(other)
      self.class.alloc(@node.bulk_insert(other))
    end
    alias :| :union
    alias :+ :union
    alias :merge :union

    # Return a new `SortedSet` which contains all the items which are members of both
    # this set and `other`. `other` can be any `Enumerable` object.
    #
    # @example
    #   Hamster::SortedSet[1, 2] & Hamster::SortedSet[2, 3]
    #   # => Hamster::SortedSet[2]
    #
    # @param other [Enumerable] The collection to intersect with
    # @return [SortedSet]
    def intersection(other)
      self.class.alloc(@node.keep_only(other))
    end
    alias :& :intersection

    # Return a new `SortedSet` with all the items in `other` removed. `other` can be
    # any `Enumerable` object.
    #
    # @example
    #   Hamster::SortedSet[1, 2] - Hamster::SortedSet[2, 3]
    #   # => Hamster::SortedSet[1]
    #
    # @param other [Enumerable] The collection to subtract from this set
    # @return [SortedSet]
    def difference(other)
      self.class.alloc(@node.bulk_delete(other))
    end
    alias :subtract :difference
    alias :- :difference

    # Return a new `SortedSet` with all the items which are members of this
    # set or of `other`, but not both. `other` can be any `Enumerable` object.
    #
    # @example
    #   Hamster::SortedSet[1, 2] ^ Hamster::SortedSet[2, 3]
    #   # => Hamster::SortedSet[1, 3]
    #
    # @param other [Enumerable] The collection to take the exclusive disjunction of
    # @return [SortedSet]
    def exclusion(other)
      ((self | other) - (self & other))
    end
    alias :^ :exclusion

    # Return `true` if all items in this set are also in `other`.
    #
    # @example
    #   Hamster::SortedSet[2, 3].subset?(Hamster::SortedSet[1, 2, 3])  # => true
    #
    # @param other [Enumerable]
    # @return [Boolean]
    def subset?(other)
      return false if other.size < size
      all? { |item| other.include?(item) }
    end

    # Return `true` if all items in `other` are also in this set.
    #
    # @example
    #   Hamster::SortedSet[1, 2, 3].superset?(Hamster::SortedSet[2, 3])  # => true
    #
    # @param other [Enumerable]
    # @return [Boolean]
    def superset?(other)
      other.subset?(self)
    end

    # Returns `true` if `other` contains all the items in this set, plus at least
    # one item which is not in this set.
    #
    # @example
    #   Hamster::SortedSet[2, 3].proper_subset?(Hamster::SortedSet[1, 2, 3])     # => true
    #   Hamster::SortedSet[1, 2, 3].proper_subset?(Hamster::SortedSet[1, 2, 3])  # => false
    #
    # @param other [Enumerable]
    # @return [Boolean]
    def proper_subset?(other)
      return false if other.size <= size
      all? { |item| other.include?(item) }
    end

    # Returns `true` if this set contains all the items in `other`, plus at least
    # one item which is not in `other`.
    #
    # @example
    #   Hamster::SortedSet[1, 2, 3].proper_superset?(Hamster::SortedSet[2, 3])     # => true
    #   Hamster::SortedSet[1, 2, 3].proper_superset?(Hamster::SortedSet[1, 2, 3])  # => false
    #
    # @param other [Enumerable]
    # @return [Boolean]
    def proper_superset?(other)
      other.proper_subset?(self)
    end

    # Return `true` if this set and `other` do not share any items.
    #
    # @example
    #   Hamster::SortedSet[1, 2].disjoint?(Hamster::SortedSet[3, 4])  # => true
    #
    # @param other [Enumerable]
    # @return [Boolean]
    def disjoint?(other)
      if size < other.size
        each { |item| return false if other.include?(item) }
      else
        other.each { |item| return false if include?(item) }
      end
      true
    end

    # Return `true` if this set and `other` have at least one item in common.
    #
    # @example
    #   Hamster::SortedSet[1, 2].intersect?(Hamster::SortedSet[2, 3])  # => true
    #
    # @param other [Enumerable]
    # @return [Boolean]
    def intersect?(other)
      !disjoint?(other)
    end

    alias :group :group_by
    alias :classify :group_by

    # Select elements greater than a value.
    #
    # @overload above(item)
    #   Return a new `SortedSet` containing all items greater than `item`.
    #   @return [SortedSet]
    #   @example
    #     s = Hamster::SortedSet[2, 4, 6, 8, 10]
    #     s.above(6)
    #     # => Hamster::SortedSet[8, 10]
    #  
    # @overload above(item)
    #   @yield [item] Once for each item greater than `item`, in order from
    #                 lowest to highest.
    #   @return [nil]
    #   @example
    #     s = Hamster::SortedSet[2, 4, 6, 8, 10]
    #     s.above(6) { |e| puts "Element: #{e}" }
    #  
    #     Element: 8
    #     Element: 10
    #     # => nil
    #
    # @param item [Object]
    def above(item, &block)
      if block_given?
        @node.each_greater(item, false, &block)
      else
        self.class.alloc(@node.suffix(item, false))
      end
    end

    # Select elements less than a value.
    #
    # @overload below(item)
    #   Return a new `SortedSet` containing all items less than `item`.
    #   @return [SortedSet]
    #   @example
    #     s = Hamster::SortedSet[2, 4, 6, 8, 10]
    #     s.below(6)
    #     # => Hamster::SortedSet[2, 4]
    #  
    # @overload below(item)
    #   @yield [item] Once for each item less than `item`, in order from lowest
    #                 to highest.
    #   @return [nil]
    #   @example
    #     s = Hamster::SortedSet[2, 4, 6, 8, 10]
    #     s.below(6) { |e| puts "Element: #{e}" }
    #  
    #     Element: 2
    #     Element: 4 
    #     # => nil
    #
    # @param item [Object]
    def below(item, &block)
      if block_given?
        @node.each_less(item, false, &block)
      else
        self.class.alloc(@node.prefix(item, false))
      end
    end

    # Select elements greater than or equal to a value.
    #
    # @overload from(item)
    #   Return a new `SortedSet` containing all items greater than or equal `item`.
    #   @return [SortedSet]
    #   @example
    #     s = Hamster::SortedSet[2, 4, 6, 8, 10]
    #     s.from(6)
    #     # => Hamster::SortedSet[6, 8, 10]
    #  
    # @overload from(item)
    #   @yield [item] Once for each item greater than or equal to `item`, in
    #                 order from lowest to highest.
    #   @return [nil]
    #   @example
    #     s = Hamster::SortedSet[2, 4, 6, 8, 10]
    #     s.from(6) { |e| puts "Element: #{e}" }
    #  
    #     Element: 6
    #     Element: 8
    #     Element: 10
    #     # => nil
    #
    # @param item [Object]
    def from(item, &block)
      if block_given?
        @node.each_greater(item, true, &block)
      else
        self.class.alloc(@node.suffix(item, true))
      end
    end

    # Select elements less than or equal to a value.
    #
    # @overload up_to(item)
    #   Return a new `SortedSet` containing all items less than or equal to 
    #   `item`.
    #
    #   @return [SortedSet]
    #   @example
    #     s = Hamster::SortedSet[2, 4, 6, 8, 10]
    #     s.upto(6)
    #     # => Hamster::SortedSet[2, 4, 6]
    #  
    # @overload up_to(item)
    #   @yield [item] Once for each item less than or equal to `item`, in order
    #                 from lowest to highest.
    #   @return [nil]
    #   @example
    #     s = Hamster::SortedSet[2, 4, 6, 8, 10]
    #     s.up_to(6) { |e| puts "Element: #{e}" }
    #  
    #     Element: 2
    #     Element: 4 
    #     Element: 6 
    #     # => nil
    #
    # @param item [Object]
    def up_to(item, &block)
      if block_given?
        @node.each_less(item, true, &block)
      else
        self.class.alloc(@node.prefix(item, true))
      end
    end

    # Select elements between two values.
    #
    # @overload between(from, to)
    #   Return a new `SortedSet` containing all items less than or equal to
    #   `to` and greater than or equal to `from`.
    #
    #   @return [SortedSet]
    #   @example
    #     s = Hamster::SortedSet[2, 4, 6, 8, 10]
    #     s.between(5, 8)
    #     # => Hamster::SortedSet[6, 8]
    #  
    # @overload between(item)
    #   @yield [item] Once for each item less than or equal to `to` and greater
    #                 than or equal to `from`, in order from lowest to highest.
    #   @return [nil]
    #   @example
    #     s = Hamster::SortedSet[2, 4, 6, 8, 10]
    #     s.between(5, 8) { |e| puts "Element: #{e}" }
    #  
    #     Element: 6
    #     Element: 8 
    #     # => nil
    #
    # @param from [Object]
    # @param to [Object]
    def between(from, to, &block)
      if block_given?
        @node.each_between(from, to, &block)
      else
        self.class.alloc(@node.between(from, to))
      end
    end

    # Return a randomly chosen item from this set. If the set is empty, return `nil`.
    #
    # @example
    #   Hamster::SortedSet[1, 2, 3, 4, 5].sample  # => 2
    #
    # @return [Object]
    def sample
      @node.at(rand(@node.size))
    end

    # Return an empty `SortedSet` instance, of the same class as this one. Useful if you
    # have multiple subclasses of `SortedSet` and want to treat them polymorphically.
    #
    # @return [SortedSet]
    def clear
      if @node.natural_order?
        self.class.empty
      else
        self.class.alloc(@node.clear)
      end
    end

    # Return true if `other` has the same type and contents as this `SortedSet`.
    #
    # @param other [Object] The object to compare with
    # @return [Boolean]
    def eql?(other)
      return true if other.equal?(self)
      return false if not instance_of?(other.class)
      return false if size != other.size
      a, b = self.to_enum, other.to_enum
      while true
        return false if !a.next.eql?(b.next)
      end
    rescue StopIteration
      true
    end

    # See `Object#hash`.
    # @return [Integer]
    def hash
      reduce(0) { |hash, item| (hash << 5) - hash + item.hash }
    end

    # @return [::Array]
    # @private
    def marshal_dump
      if @node.natural_order?
        to_a
      else
        raise TypeError, "can't dump SortedSet with custom sort order"
      end
    end

    # @private
    def marshal_load(array)
      initialize(array)
    end

    private

    def subsequence(from, length)
      return nil if from > @node.size || from < 0 || length < 0
      length = @node.size - from if @node.size < from + length
      if length == 0
        if @node.natural_order?
          return self.class.empty
        else
          return self.class.alloc(@node.clear)
        end
      end
      self.class.alloc(@node.slice(from, length))
    end

    # Return a new `SortedSet` which is derived from this one, using a modified
    # {AVLNode}.  The new `SortedSet` will retain the existing comparator, if
    # there is one.
    def derive_new_sorted_set(node)
      if node.equal?(@node)
        self
      elsif node.empty?
        clear
      else
        self.class.alloc(node)
      end
    end

    # @private
    class AVLNode
      def self.from_items(items, comparator, from = 0, to = items.size-1) # items must be sorted
        size = to - from + 1
        if size >= 3
          middle = (to + from) / 2
          AVLNode.new(items[middle], comparator, AVLNode.from_items(items, comparator, from, middle-1), AVLNode.from_items(items, comparator, middle+1, to))
        elsif size == 2
          empty = AVLNode::Empty.new(comparator)
          AVLNode.new(items[from], comparator, empty, AVLNode.new(items[from+1], comparator, empty, empty))
        elsif size == 1
          empty = AVLNode::Empty.new(comparator)
          AVLNode.new(items[from], comparator, empty, empty)
        elsif size == 0
          AVLNode::Empty.new(comparator)
        end
      end

      def initialize(item, comparator, left, right)
        @item, @comparator, @left, @right = item, comparator, left, right
        @height = ((right.height > left.height) ? right.height : left.height) + 1
        @size   = right.size + left.size + 1
      end
      attr_reader :item, :left, :right, :height, :size

      def from_items(items)
        AVLNode.from_items(items.sort(&@comparator), @comparator)
      end

      def natural_order?
        false
      end

      def empty?
        false
      end

      def clear
        AVLNode::Empty.new(@comparator)
      end

      def derive(item, left, right)
        AVLNode.new(item, @comparator, left, right)
      end

      def insert(item)
        dir = direction(item)
        if dir == 0
          throw :present
        elsif dir > 0
          rebalance_right(@left, @right.insert(item))
        else
          rebalance_left(@left.insert(item), @right)
        end
      end

      def bulk_insert(items)
        return self if items.empty?
        if items.size == 1
          catch :present do
            return insert(items.first)
          end
          return self
        end
        left, right = partition(items)

        if right.size > left.size
          rebalance_right(@left.bulk_insert(left), @right.bulk_insert(right))
        else
          rebalance_left(@left.bulk_insert(left), @right.bulk_insert(right))
        end
      end

      def delete(item)
        dir = direction(item)
        if dir == 0
          if @right.empty?
            return @left # replace this node with its only child
          elsif @left.empty?
            return @right # likewise
          end

          if balance > 0
            # tree is leaning to the left. replace with highest node on that side
            replace_with = @left.max
            derive(replace_with, @left.delete(replace_with), @right)
          else
            # tree is leaning to the right. replace with lowest node on that side
            replace_with = @right.min
            derive(replace_with, @left, @right.delete(replace_with))
          end
        elsif dir > 0
          rebalance_left(@left, @right.delete(item))
        else
          rebalance_right(@left.delete(item), @right)
        end
      end

      def bulk_delete(items)
        return self if items.empty?
        if items.size == 1
          catch :not_present do
            return delete(items.first)
          end
          return self
        end

        left, right, keep_item = [], [], true
        items.each do |item|
          dir = direction(item)
          if dir > 0
            right << item
          elsif dir < 0
            left << item
          else
            keep_item = false
          end
        end

        left  = @left.bulk_delete(left)
        right = @right.bulk_delete(right)
        finish_removal(keep_item, left, right)
      end

      def keep_only(items)
        return clear if items.empty?

        left, right, keep_item = [], [], false
        items.each do |item|
          dir = direction(item)
          if dir > 0
            right << item
          elsif dir < 0
            left << item
          else
            keep_item = true
          end
        end

        left  = @left.keep_only(left)
        right = @right.keep_only(right)
        finish_removal(keep_item, left, right)
      end

      def finish_removal(keep_item, left, right)
        # deletion of items may have occurred on left and right sides
        # now we may also need to delete the current item
        if keep_item
          rebalance(left, right) # no need to delete the current item
        elsif left.empty?
          right
        elsif right.empty?
          left
        elsif left.height > right.height
          replace_with = left.max
          derive(replace_with, left.delete(replace_with), right)
        else
          replace_with = right.min
          derive(replace_with, left, right.delete(replace_with))
        end
      end

      def prefix(item, inclusive)
        dir = direction(item)
        if dir > 0 || (inclusive && dir == 0)
          rebalance_left(@left, @right.prefix(item, inclusive))
        else
          @left.prefix(item, inclusive)
        end
      end

      def suffix(item, inclusive)
        dir = direction(item)
        if dir < 0 || (inclusive && dir == 0)
          rebalance_right(@left.suffix(item, inclusive), @right)
        else
          @right.suffix(item, inclusive)
        end
      end

      def between(from, to)
        if direction(from) > 0 # all on the right
          @right.between(from, to)
        elsif direction(to) < 0 # all on the left
          @left.between(from, to)
        else
          left = @left.suffix(from, true)
          right = @right.prefix(to, true)
          rebalance(left, right)
        end
      end

      def each_less(item, inclusive, &block)
        dir = direction(item)
        if dir > 0 || (inclusive && dir == 0)
          @left.each(&block)
          yield @item
          @right.each_less(item, inclusive, &block)
        else
          @left.each_less(item, inclusive, &block)
        end
      end

      def each_greater(item, inclusive, &block)
        dir = direction(item)
        if dir < 0 || (inclusive && dir == 0)
          @left.each_greater(item, inclusive, &block)
          yield @item
          @right.each(&block)
        else
          @right.each_greater(item, inclusive, &block)
        end
      end

      def each_between(from, to, &block)
        if direction(from) > 0 # all on the right
          @right.each_between(from, to, &block)
        elsif direction(to) < 0 # all on the left
          @left.each_between(from, to, &block)
        else
          @left.each_greater(from, true, &block)
          yield @item
          @right.each_less(to, true, &block)
        end
      end

      def each(&block)
        @left.each(&block)
        yield @item
        @right.each(&block)
      end

      def reverse_each(&block)
        @right.reverse_each(&block)
        yield @item
        @left.reverse_each(&block)
      end

      def drop(n)
        if n >= @size
          clear
        elsif n <= 0
          self
        elsif @left.size >= n
          rebalance_right(@left.drop(n), @right)
        elsif @left.size + 1 == n
          @right
        else
          @right.drop(n - @left.size - 1)
        end
      end

      def take(n)
        if n >= @size
          self
        elsif n <= 0
          clear
        elsif @left.size >= n
          @left.take(n)
        else
          rebalance_left(@left, @right.take(n - @left.size - 1))
        end
      end

      def include?(item)
        dir = direction(item)
        if dir == 0
          true
        elsif dir > 0
          @right.include?(item)
        else
          @left.include?(item)
        end
      end

      def at(index)
        if index < @left.size
          @left.at(index)
        elsif index > @left.size
          @right.at(index - @left.size - 1)
        else
          @item
        end
      end

      def max
        @right.empty? ? @item : @right.max
      end

      def min
        @left.empty? ? @item : @left.min
      end

      def balance
        @left.height - @right.height
      end

      def slice(from, length)
        if length <= 0
          clear
        elsif from + length <= @left.size
          @left.slice(from, length)
        elsif from > @left.size
          @right.slice(from - @left.size - 1, length)
        else
          left  = @left.slice(from, @left.size - from)
          right = @right.slice(0, from + length - @left.size - 1)
          rebalance(left, right)
        end
      end

      def partition(items)
        left, right = [], []
        items.each do |item|
          dir = direction(item)
          if dir > 0
            right << item
          elsif dir < 0
            left << item
          end
        end
        [left, right]
      end

      def rebalance(left, right)
        if left.height > right.height
          rebalance_left(left, right)
        else
          rebalance_right(left, right)
        end
      end

      def rebalance_left(left, right)
        # the tree might be unbalanced to the left (paths on the left too long)
        balance = left.height - right.height
        if balance >= 2
          if left.balance > 0
            # single right rotation
            derive(left.item, left.left, derive(@item, left.right, right))
          else
            # left rotation, then right
            derive(left.right.item, derive(left.item, left.left, left.right.left), derive(@item, left.right.right, right))
          end
        else
          derive(@item, left, right)
        end
      end

      def rebalance_right(left, right)
        # the tree might be unbalanced to the right (paths on the right too long)
        balance = left.height - right.height
        if balance <= -2
          if right.balance > 0
            # right rotation, then left
            derive(right.left.item, derive(@item, left, right.left.left), derive(right.item, right.left.right, right.right))
          else
            # single left rotation
            derive(right.item, derive(@item, left, right.left), right.right)
          end
        else
          derive(@item, left, right)
        end
      end

      def direction(item)
        @comparator.call(item, @item)
      end

      # @private
      class Empty
        def initialize(comparator); @comparator = comparator; end
        def natural_order?; false; end
        def left;  self;    end
        def right; self;    end
        def height;   0;    end
        def size;     0;    end
        def min;    nil;    end
        def max;    nil;    end
        def each;           end
        def reverse_each;   end
        def at(index); nil; end
        def insert(item)
          AVLNode.new(item, @comparator, self, self)
        end
        def bulk_insert(items)
          items = items.to_a if !items.is_a?(Array)
          AVLNode.from_items(items.sort(&@comparator), @comparator)
        end
        def bulk_delete(items); self; end
        def keep_only(items);   self; end
        def delete(item);       throw :not_present; end
        def include?(item);     false; end
        def prefix(item, inclusive); self; end
        def suffix(item, inclusive); self; end
        def between(from, to);       self; end
        def each_greater(item, inclusive); end
        def each_less(item, inclusive);    end
        def each_between(item, inclusive); end
        def drop(n);             self; end
        def take(n);             self; end
        def empty?;              true; end
        def slice(from, length); self; end
      end
    end

    # @private
    # AVL node which does not use a comparator function; it keeps items sorted
    #   in their natural order
    class PlainAVLNode < AVLNode
      def self.from_items(items, from = 0, to = items.size-1) # items must be sorted
        size = to - from + 1
        if size >= 3
          middle = (to + from) / 2
          PlainAVLNode.new(items[middle], PlainAVLNode.from_items(items, from, middle-1), PlainAVLNode.from_items(items, middle+1, to))
        elsif size == 2
          PlainAVLNode.new(items[from], PlainAVLNode::EmptyNode, PlainAVLNode.new(items[from+1], PlainAVLNode::EmptyNode, PlainAVLNode::EmptyNode))
        elsif size == 1
          PlainAVLNode.new(items[from], PlainAVLNode::EmptyNode, PlainAVLNode::EmptyNode)
        elsif size == 0
          PlainAVLNode::EmptyNode
        end
      end

      def initialize(item, left, right)
        @item,  @left, @right = item, left, right
        @height = ((right.height > left.height) ? right.height : left.height) + 1
        @size   = right.size + left.size + 1
      end
      attr_reader :item, :left, :right, :height, :size

      def from_items(items)
        PlainAVLNode.from_items(items.sort)
      end

      def natural_order?
        true
      end

      def clear
        PlainAVLNode::EmptyNode
      end

      def derive(item, left, right)
        PlainAVLNode.new(item, left, right)
      end

      def direction(item)
        item <=> @item
      end

      # @private
      class Empty < AVLNode::Empty
        def initialize;           end
        def natural_order?; true; end
        def insert(item)
          PlainAVLNode.new(item, self, self)
        end
        def bulk_insert(items)
          items = items.to_a if !items.is_a?(Array)
          PlainAVLNode.from_items(items.sort)
        end
      end

      EmptyNode = PlainAVLNode::Empty.new
    end
  end

  # The canonical empty `SortedSet`. Returned by `SortedSet[]`
  # when invoked with no arguments; also returned by `SortedSet.empty`. Prefer using
  # this one rather than creating many empty sorted sets using `SortedSet.new`.
  #
  # @private
  EmptySortedSet = Hamster::SortedSet.empty
end
