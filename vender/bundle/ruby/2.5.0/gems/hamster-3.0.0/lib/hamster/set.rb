require "hamster/immutable"
require "hamster/undefined"
require "hamster/enumerable"
require "hamster/hash"
require "hamster/trie"
require "hamster/sorted_set"
require "set"

module Hamster

  # `Hamster::Set` is a collection of unordered values with no duplicates. Testing whether
  # an object is present in the `Set` can be done in constant time. `Set` is also `Enumerable`, so you can
  # iterate over the members of the set with {#each}, transform them with {#map}, filter
  # them with {#select}, and so on. Some of the `Enumerable` methods are overridden to
  # return Hamster collections.
  #
  # Like the `Set` class in Ruby's standard library, which we will call RubySet,
  # `Hamster::Set` defines equivalency of objects using `#hash` and `#eql?`. No two
  # objects with the same `#hash` code, and which are also `#eql?`, can coexist in the
  # same `Set`. If one is already in the `Set`, attempts to add another one will have
  # no effect.
  #
  # `Set`s have no natural ordering and cannot be compared using `#<=>`. However, they
  # define {#<}, {#>}, {#<=}, and {#>=} as shorthand for {#proper_subset?},
  # {#proper_superset?}, {#subset?}, and {#superset?} respectively.
  #
  # The basic set-theoretic operations {#union}, {#intersection}, {#difference}, and
  # {#exclusion} work with any `Enumerable` object.
  #
  # A `Set` can be created in either of the following ways:
  #
  #     Hamster::Set.new([1, 2, 3]) # any Enumerable can be used to initialize
  #     Hamster::Set['A', 'B', 'C', 'D']
  #
  # The latter 2 forms of initialization can be used with your own, custom subclasses
  # of `Hamster::Set`.
  #
  # Unlike RubySet, all methods which you might expect to "modify" a `Hamster::Set`
  # actually return a new set and leave the existing one unchanged.
  #
  # @example
  #   set1 = Hamster::Set[1, 2] # => Hamster::Set[1, 2]
  #   set2 = Hamster::Set[1, 2] # => Hamster::Set[1, 2]
  #   set1 == set2              # => true
  #   set3 = set1.add("foo")    # => Hamster::Set[1, 2, "foo"]
  #   set3 - set2               # => Hamster::Set["foo"]
  #   set3.subset?(set1)        # => false
  #   set1.subset?(set3)        # => true
  #
  class Set
    include Immutable
    include Enumerable

    class << self
      # Create a new `Set` populated with the given items.
      # @return [Set]
      def [](*items)
        items.empty? ? empty : new(items)
      end

      # Return an empty `Set`. If used on a subclass, returns an empty instance
      # of that class.
      #
      # @return [Set]
      def empty
        @empty ||= self.new
      end

      # "Raw" allocation of a new `Set`. Used internally to create a new
      # instance quickly after obtaining a modified {Trie}.
      #
      # @return [Set]
      # @private
      def alloc(trie = EmptyTrie)
        allocate.tap { |s| s.instance_variable_set(:@trie, trie) }
      end
    end

    def initialize(items=[])
      @trie = Trie.new(0)
      items.each { |item| @trie.put!(item, nil) }
    end

    # Return `true` if this `Set` contains no items.
    # @return [Boolean]
    def empty?
      @trie.empty?
    end

    # Return the number of items in this `Set`.
    # @return [Integer]
    def size
      @trie.size
    end
    alias :length :size

    # Return a new `Set` with `item` added. If `item` is already in the set,
    # return `self`.
    #
    # @example
    #   Hamster::Set[1, 2, 3].add(4) # => Hamster::Set[1, 2, 4, 3]
    #   Hamster::Set[1, 2, 3].add(2) # => Hamster::Set[1, 2, 3]
    #
    # @param item [Object] The object to add
    # @return [Set]
    def add(item)
      include?(item) ? self : self.class.alloc(@trie.put(item, nil))
    end
    alias :<< :add

    # If `item` is not a member of this `Set`, return a new `Set` with `item` added.
    # Otherwise, return `false`.
    #
    # @example
    #   Hamster::Set[1, 2, 3].add?(4) # => Hamster::Set[1, 2, 4, 3]
    #   Hamster::Set[1, 2, 3].add?(2) # => false
    #
    # @param item [Object] The object to add
    # @return [Set, false]
    def add?(item)
      !include?(item) && add(item)
    end

    # Return a new `Set` with `item` removed. If `item` is not a member of the set,
    # return `self`.
    #
    # @example
    #   Hamster::Set[1, 2, 3].delete(1)  # => Hamster::Set[2, 3]
    #   Hamster::Set[1, 2, 3].delete(99) # => Hamster::Set[1, 2, 3]
    #
    # @param item [Object] The object to remove
    # @return [Set]
    def delete(item)
      trie = @trie.delete(item)
      new_trie(trie)
    end

    # If `item` is a member of this `Set`, return a new `Set` with `item` removed.
    # Otherwise, return `false`.
    #
    # @example
    #   Hamster::Set[1, 2, 3].delete?(1)  # => Hamster::Set[2, 3]
    #   Hamster::Set[1, 2, 3].delete?(99) # => false
    #
    # @param item [Object] The object to remove
    # @return [Set, false]
    def delete?(item)
      include?(item) && delete(item)
    end

    # Call the block once for each item in this `Set`. No specific iteration order
    # is guaranteed, but the order will be stable for any particular `Set`. If
    # no block is given, an `Enumerator` is returned instead.
    #
    # @example
    #   Hamster::Set["Dog", "Elephant", "Lion"].each { |e| puts e }
    #   Elephant
    #   Dog
    #   Lion
    #   # => Hamster::Set["Dog", "Elephant", "Lion"]
    #
    # @yield [item] Once for each item.
    # @return [self, Enumerator]
    def each
      return to_enum if not block_given?
      @trie.each { |key, _| yield(key) }
      self
    end

    # Call the block once for each item in this `Set`. Iteration order will be
    # the opposite of {#each}. If no block is given, an `Enumerator` is
    # returned instead.
    #
    # @example
    #   Hamster::Set["Dog", "Elephant", "Lion"].reverse_each { |e| puts e }
    #   Lion
    #   Dog
    #   Elephant
    #   # => Hamster::Set["Dog", "Elephant", "Lion"]
    #
    # @yield [item] Once for each item.
    # @return [self]
    def reverse_each
      return enum_for(:reverse_each) if not block_given?
      @trie.reverse_each { |key, _| yield(key) }
      self
    end

    # Return a new `Set` with all the items for which the block returns true.
    #
    # @example
    #   Hamster::Set["Elephant", "Dog", "Lion"].select { |e| e.size >= 4 }
    #   # => Hamster::Set["Elephant", "Lion"]
    # @yield [item] Once for each item.
    # @return [Set]
    def select
      return enum_for(:select) unless block_given?
      trie = @trie.select { |key, _| yield(key) }
      new_trie(trie)
    end
    alias :find_all :select
    alias :keep_if  :select

    # Call the block once for each item in this `Set`. All the values returned
    # from the block will be gathered into a new `Set`. If no block is given,
    # an `Enumerator` is returned instead.
    #
    # @example
    #   Hamster::Set["Cat", "Elephant", "Dog", "Lion"].map { |e| e.size }
    #   # => Hamster::Set[8, 4, 3]
    #
    # @yield [item] Once for each item.
    # @return [Set]
    def map
      return enum_for(:map) if not block_given?
      return self if empty?
      self.class.new(super)
    end
    alias :collect :map

    # Return `true` if the given item is present in this `Set`. More precisely,
    # return `true` if an object with the same `#hash` code, and which is also `#eql?`
    # to the given object is present.
    #
    # @example
    #   Hamster::Set["A", "B", "C"].include?("B") # => true
    #   Hamster::Set["A", "B", "C"].include?("Z") # => false
    #
    # @param object [Object] The object to check for
    # @return [Boolean]
    def include?(object)
      @trie.key?(object)
    end
    alias :member? :include?

    # Return a member of this `Set`. The member chosen will be the first one which
    # would be yielded by {#each}. If the set is empty, return `nil`.
    #
    # @example
    #   Hamster::Set["A", "B", "C"].first # => "C"
    #
    # @return [Object]
    def first
      (entry = @trie.at(0)) && entry[0]
    end

    # Return a {SortedSet} which contains the same items as this `Set`, ordered by
    # the given comparator block.
    #
    # @example
    #   Hamster::Set["Elephant", "Dog", "Lion"].sort
    #   # => Hamster::SortedSet["Dog", "Elephant", "Lion"]
    #   Hamster::Set["Elephant", "Dog", "Lion"].sort { |a,b| a.size <=> b.size }
    #   # => Hamster::SortedSet["Dog", "Lion", "Elephant"]
    #
    # @yield [a, b] Any number of times with different pairs of elements.
    # @yieldreturn [Integer] Negative if the first element should be sorted
    #                        lower, positive if the latter element, or 0 if
    #                        equal.
    # @return [SortedSet]
    def sort(&comparator)
      SortedSet.new(self.to_a, &comparator)
    end

    # Return a {SortedSet} which contains the same items as this `Set`, ordered
    # by mapping each item through the provided block to obtain sort keys, and
    # then sorting the keys.
    #
    # @example
    #   Hamster::Set["Elephant", "Dog", "Lion"].sort_by { |e| e.size }
    #   # => Hamster::SortedSet["Dog", "Lion", "Elephant"]
    #
    # @yield [item] Once for each item to create the set, and then potentially
    #               again depending on what operations are performed on the
    #               returned {SortedSet}. As such, it is recommended that the
    #               block be a pure function.
    # @yieldreturn [Object] sort key for the item
    # @return [SortedSet]
    def sort_by(&mapper)
      SortedSet.new(self.to_a, &mapper)
    end

    # Return a new `Set` which contains all the members of both this `Set` and `other`.
    # `other` can be any `Enumerable` object.
    #
    # @example
    #   Hamster::Set[1, 2] | Hamster::Set[2, 3] # => Hamster::Set[1, 2, 3]
    #
    # @param other [Enumerable] The collection to merge with
    # @return [Set]
    def union(other)
      if other.is_a?(Hamster::Set)
        if other.size > size
          small_set_pairs = @trie
          large_set_trie = other.instance_variable_get(:@trie)
        else
          small_set_pairs = other.instance_variable_get(:@trie)
          large_set_trie = @trie
        end
      else
        if other.respond_to?(:lazy)
          small_set_pairs = other.lazy.map { |e| [e, nil] }
        else
          small_set_pairs = other.map { |e| [e, nil] }
        end
        large_set_trie = @trie
      end

      trie = large_set_trie.bulk_put(small_set_pairs)
      new_trie(trie)
    end
    alias :| :union
    alias :+ :union
    alias :merge :union

    # Return a new `Set` which contains all the items which are members of both
    # this `Set` and `other`. `other` can be any `Enumerable` object.
    #
    # @example
    #   Hamster::Set[1, 2] & Hamster::Set[2, 3] # => Hamster::Set[2]
    #
    # @param other [Enumerable] The collection to intersect with
    # @return [Set]
    def intersection(other)
      if other.size < @trie.size
        if other.is_a?(Hamster::Set)
          trie = other.instance_variable_get(:@trie).select { |key, _| include?(key) }
        else
          trie = Trie.new(0)
          other.each { |obj| trie.put!(obj, nil) if include?(obj) }
        end
      else
        trie = @trie.select { |key, _| other.include?(key) }
      end
      new_trie(trie)
    end
    alias :& :intersection

    # Return a new `Set` with all the items in `other` removed. `other` can be
    # any `Enumerable` object.
    #
    # @example
    #   Hamster::Set[1, 2] - Hamster::Set[2, 3] # => Hamster::Set[1]
    #
    # @param other [Enumerable] The collection to subtract from this set
    # @return [Set]
    def difference(other)
      trie = if (@trie.size <= other.size) && (other.is_a?(Hamster::Set) || (defined?(::Set) && other.is_a?(::Set)))
        @trie.select { |key, _| !other.include?(key) }
      else
        @trie.bulk_delete(other)
      end
      new_trie(trie)
    end
    alias :subtract :difference
    alias :- :difference

    # Return a new `Set` which contains all the items which are members of this
    # `Set` or of `other`, but not both. `other` can be any `Enumerable` object.
    #
    # @example
    #   Hamster::Set[1, 2] ^ Hamster::Set[2, 3] # => Hamster::Set[1, 3]
    #
    # @param other [Enumerable] The collection to take the exclusive disjunction of
    # @return [Set]
    def exclusion(other)
      ((self | other) - (self & other))
    end
    alias :^ :exclusion

    # Return `true` if all items in this `Set` are also in `other`.
    #
    # @example
    #   Hamster::Set[2, 3].subset?(Hamster::Set[1, 2, 3]) # => true
    #
    # @param other [Set]
    # @return [Boolean]
    def subset?(other)
      return false if other.size < size

      # This method has the potential to be very slow if 'other' is a large Array, so to avoid that,
      #   we convert those Arrays to Sets before checking presence of items
      # Time to convert Array -> Set is linear in array.size
      # Time to check for presence of all items in an Array is proportional to set.size * array.size
      # Note that both sides of that equation have array.size -- hence those terms cancel out,
      #   and the break-even point is solely dependent on the size of this collection
      # After doing some benchmarking to estimate the constants, it appears break-even is at ~190 items
      # We also check other.size, to avoid the more expensive #is_a? checks in cases where it doesn't matter
      #
      if other.size >= 150 && @trie.size >= 190 && !(other.is_a?(Hamster::Set) || other.is_a?(::Set))
        other = ::Set.new(other)
      end
      all? { |item| other.include?(item) }
    end
    alias :<= :subset?

    # Return `true` if all items in `other` are also in this `Set`.
    #
    # @example
    #   Hamster::Set[1, 2, 3].superset?(Hamster::Set[2, 3]) # => true
    #
    # @param other [Set]
    # @return [Boolean]
    def superset?(other)
      other.subset?(self)
    end
    alias :>= :superset?

    # Returns `true` if `other` contains all the items in this `Set`, plus at least
    # one item which is not in this set.
    #
    # @example
    #   Hamster::Set[2, 3].proper_subset?(Hamster::Set[1, 2, 3])    # => true
    #   Hamster::Set[1, 2, 3].proper_subset?(Hamster::Set[1, 2, 3]) # => false
    #
    # @param other [Set]
    # @return [Boolean]
    def proper_subset?(other)
      return false if other.size <= size
      # See comments above
      if other.size >= 150 && @trie.size >= 190 && !(other.is_a?(Hamster::Set) || other.is_a?(::Set))
        other = ::Set.new(other)
      end
      all? { |item| other.include?(item) }
    end
    alias :< :proper_subset?

    # Returns `true` if this `Set` contains all the items in `other`, plus at least
    # one item which is not in `other`.
    #
    # @example
    #   Hamster::Set[1, 2, 3].proper_superset?(Hamster::Set[2, 3])    # => true
    #   Hamster::Set[1, 2, 3].proper_superset?(Hamster::Set[1, 2, 3]) # => false
    #
    # @param other [Set]
    # @return [Boolean]
    def proper_superset?(other)
      other.proper_subset?(self)
    end
    alias :> :proper_superset?

    # Return `true` if this `Set` and `other` do not share any items.
    #
    # @example
    #   Hamster::Set[1, 2].disjoint?(Hamster::Set[8, 9]) # => true
    #
    # @param other [Set]
    # @return [Boolean]
    def disjoint?(other)
      if other.size <= size
        other.each { |item| return false if include?(item) }
      else
        # See comment on #subset?
        if other.size >= 150 && @trie.size >= 190 && !(other.is_a?(Hamster::Set) || other.is_a?(::Set))
          other = ::Set.new(other)
        end
        each { |item| return false if other.include?(item) }
      end
      true
    end

    # Return `true` if this `Set` and `other` have at least one item in common.
    #
    # @example
    #   Hamster::Set[1, 2].intersect?(Hamster::Set[2, 3]) # => true
    #
    # @param other [Set]
    # @return [Boolean]
    def intersect?(other)
      !disjoint?(other)
    end

    # Recursively insert the contents of any nested `Set`s into this `Set`, and
    # remove them.
    #
    # @example
    #   Hamster::Set[Hamster::Set[1, 2], Hamster::Set[3, 4]].flatten
    #   # => Hamster::Set[1, 2, 3, 4]
    #
    # @return [Set]
    def flatten
      reduce(self.class.empty) do |set, item|
        next set.union(item.flatten) if item.is_a?(Set)
        set.add(item)
      end
    end

    alias :group :group_by
    alias :classify :group_by

    # Return a randomly chosen item from this `Set`. If the set is empty, return `nil`.
    #
    # @example
    #   Hamster::Set[1, 2, 3, 4, 5].sample # => 3
    #
    # @return [Object]
    def sample
      empty? ? nil : @trie.at(rand(size))[0]
    end

    # Return an empty `Set` instance, of the same class as this one. Useful if you
    # have multiple subclasses of `Set` and want to treat them polymorphically.
    #
    # @return [Set]
    def clear
      self.class.empty
    end

    # Return true if `other` has the same type and contents as this `Set`.
    #
    # @param other [Object] The object to compare with
    # @return [Boolean]
    def eql?(other)
      return true if other.equal?(self)
      return false if not instance_of?(other.class)
      other_trie = other.instance_variable_get(:@trie)
      return false if @trie.size != other_trie.size
      @trie.each do |key, _|
        return false if !other_trie.key?(key)
      end
      true
    end
    alias :== :eql?

    # See `Object#hash`.
    # @return [Integer]
    def hash
      reduce(0) { |hash, item| (hash << 5) - hash + item.hash }
    end

    undef :"<=>" # Sets are not ordered, so Enumerable#<=> will give a meaningless result
    undef :each_index # Set members cannot be accessed by 'index', so #each_index is not meaningful

    # Return `self`.
    #
    # @return [self]
    def to_set
      self
    end

    # @private
    def marshal_dump
      output = {}
      each do |key|
        output[key] = nil
      end
      output
    end

    # @private
    def marshal_load(dictionary)
      @trie = dictionary.reduce(EmptyTrie) do |trie, key_value|
        trie.put(key_value.first, nil)
      end
    end

    private

    def new_trie(trie)
      if trie.empty?
        self.class.empty
      elsif trie.equal?(@trie)
        self
      else
        self.class.alloc(trie)
      end
    end
  end

  # The canonical empty `Set`. Returned by `Set[]` when
  # invoked with no arguments; also returned by `Set.empty`. Prefer using this
  # one rather than creating many empty sets using `Set.new`.
  #
  # @private
  EmptySet = Hamster::Set.empty
end
