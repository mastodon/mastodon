module Hamster
  # Helper module for Hamster's sequential collections
  #
  # Classes including `Hamster::Enumerable` must implement:
  #
  # - `#each` (just like `::Enumerable`).
  # - `#select`, which takes a block, and returns an instance of the same class
  #     with only the items for which the block returns a true value
  module Enumerable
    include ::Enumerable

    # Return a new collection with all the elements for which the block returns false.
    def reject
      return enum_for(:reject) if not block_given?
      select { |item| !yield(item) }
    end
    alias :delete_if :reject

    # Return a new collection with all `nil` elements removed.
    def compact
      select { |item| !item.nil? }
    end

    # Search the collection for elements which are `#===` to `item`. Yield them to
    # the optional code block if provided, and return them as a new collection.
    def grep(pattern, &block)
      result = select { |item| pattern === item }
      result = result.map(&block) if block_given?
      result
    end

    # Search the collection for elements which are not `#===` to `item`. Yield
    # them to the optional code block if provided, and return them as a new
    # collection.
    def grep_v(pattern, &block)
      result = select { |item| !(pattern === item) }
      result = result.map(&block) if block_given?
      result
    end

    # Yield all integers from 0 up to, but not including, the number of items in
    # this collection. For collections which provide indexed access, these are all
    # the valid, non-negative indices into the collection.
    def each_index(&block)
      return enum_for(:each_index) unless block_given?
      0.upto(size-1, &block)
      self
    end

    # Multiply all the items (presumably numeric) in this collection together.
    def product
      reduce(1, &:*)
    end

    # Add up all the items (presumably numeric) in this collection.
    def sum
      reduce(0, &:+)
    end

    # Return 2 collections, the first containing all the elements for which the block
    # evaluates to true, the second containing the rest.
    def partition
      return enum_for(:partition) if not block_given?
      a,b = super
      [self.class.new(a), self.class.new(b)].freeze
    end

    # Groups the collection into sub-collections by the result of yielding them to
    # the block. Returns a {Hash} where the keys are return values from the block,
    # and the values are sub-collections. All the sub-collections are built up from
    # `empty_group`, which should respond to `#add` by returning a new collection
    # with an added element.
    def group_by_with(empty_group, &block)
      block ||= lambda { |item| item }
      reduce(EmptyHash) do |hash, item|
        key = block.call(item)
        group = hash.get(key) || empty_group
        hash.put(key, group.add(item))
      end
    end
    protected :group_by_with

    # Groups the collection into sub-collections by the result of yielding them to
    # the block. Returns a {Hash} where the keys are return values from the block,
    # and the values are sub-collections (of the same type as this one).
    def group_by(&block)
      group_by_with(self.class.empty, &block)
    end

    # Compare with `other`, and return 0, 1, or -1 if it is (respectively) equal to,
    # greater than, or less than this collection.
    def <=>(other)
      return 0 if self.equal?(other)
      enum1, enum2 = self.to_enum, other.to_enum
      loop do
        item1 = enum1.next
        item2 = enum2.next
        comp  = (item1 <=> item2)
        return comp if comp != 0
      end
      size1, size2 = self.size, other.size
      return 0 if size1 == size2
      size1 > size2 ? 1 : -1
    end

    # Return true if `other` contains the same elements, in the same order.
    # @return [Boolean]
    def ==(other)
      self.eql?(other) || other.respond_to?(:to_ary) && to_ary.eql?(other.to_ary)
    end

    # Convert all the elements into strings and join them together, separated by
    # `separator`. By default, the `separator` is `$,`, the global default string
    # separator, which is normally `nil`.
    def join(separator = $,)
      result = ""
      if separator
        each_with_index { |obj, i| result << separator if i > 0; result << obj.to_s }
      else
        each { |obj| result << obj.to_s }
      end
      result
    end

    # Convert this collection to a {Set}.
    def to_set
      Set.new(self)
    end

    # Convert this collection to a programmer-readable `String` representation.
    def inspect
      result = "#{self.class}["
      each_with_index { |obj, i| result << ', ' if i > 0; result << obj.inspect }
      result << "]"
    end

    # @private
    def pretty_print(pp)
      pp.group(1, "#{self.class}[", "]") do
        pp.breakable ''
        pp.seplist(self) { |obj| obj.pretty_print(pp) }
      end
    end

    alias :to_ary :to_a
    alias :index :find_index

    ## Compatibility fixes

    if RUBY_ENGINE == 'rbx'
      # Rubinius implements Enumerable#sort_by using Enumerable#map
      # Because we do our own, custom implementations of #map, that doesn't work well
      # @private
      def sort_by(&block)
        result = to_a
        result.frozen? ? result.sort_by(&block) : result.sort_by!(&block)
      end
    end
  end
end
