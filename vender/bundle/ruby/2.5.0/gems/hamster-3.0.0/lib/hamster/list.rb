require "thread"
require "set"
require "concurrent/atomics"

require "hamster/undefined"
require "hamster/enumerable"
require "hamster/hash"
require "hamster/set"

module Hamster
  class << self

    # Create a lazy, infinite list.
    #
    # The given block is called as necessary to return successive elements of the list.
    #
    # @example
    #   Hamster.stream { :hello }.take(3)
    #   # => Hamster::List[:hello, :hello, :hello]
    #
    # @return [List]
    def stream(&block)
      return EmptyList unless block_given?
      LazyList.new { Cons.new(yield, stream(&block)) }
    end

    # Construct a list of consecutive integers.
    #
    # @example
    #   Hamster.interval(5,9)
    #   # => Hamster::List[5, 6, 7, 8, 9]
    #
    # @param from [Integer] Start value, inclusive
    # @param to [Integer] End value, inclusive
    # @return [List]
    def interval(from, to)
      return EmptyList if from > to
      interval_exclusive(from, to.next)
    end

    # Create an infinite list repeating the same item indefinitely
    #
    # @example
    #   Hamster.repeat(:chunky).take(4)
    #   => Hamster::List[:chunky, :chunky, :chunky, :chunky]
    #
    # @return [List]
    def repeat(item)
      LazyList.new { Cons.new(item, repeat(item)) }
    end

    # Create a list that contains a given item a fixed number of times
    #
    # @example
    #   Hamster.replicate(3, :hamster)
    #   #=> Hamster::List[:hamster, :hamster, :hamster]
    #
    # @return [List]
    def replicate(number, item)
      repeat(item).take(number)
    end

    # Create an infinite list where each item is derived from the previous one,
    # using the provided block
    #
    # @example
    #   Hamster.iterate(0) { |i| i.next }.take(5)
    #   # => Hamster::List[0, 1, 2, 3, 4]
    #
    # @param [Object] item Starting value
    # @yieldparam [Object] previous The previous value
    # @yieldreturn [Object] The next value
    # @return [List]
    def iterate(item, &block)
      LazyList.new { Cons.new(item, iterate(yield(item), &block)) }
    end

    # Turn an `Enumerator` into a `Hamster::List`. The result is a lazy
    # collection where the values are memoized as they are generated.
    #
    # If your code uses multiple threads, you need to make sure that the returned
    # lazy collection is realized on a single thread only. Otherwise, a `FiberError`
    # will be raised. After the collection is realized, it can be used from other
    # threads as well.
    #
    # @example
    #   def rg; loop { yield rand(100) }; end
    #   Hamster.enumerate(to_enum(:rg)).take(10)
    #
    # @param enum [Enumerator] The object to iterate over
    # @return [List]
    def enumerate(enum)
      LazyList.new do
        begin
          Cons.new(enum.next, enumerate(enum))
        rescue StopIteration
          EmptyList
        end
      end
    end

    private

    def interval_exclusive(from, to)
      return EmptyList if from == to
      LazyList.new { Cons.new(from, interval_exclusive(from.next, to)) }
    end
  end

  # A `List` can be constructed with {List.[] List[]}, or {Enumerable#to_list}.
  # It consists of a *head* (the first element) and a *tail* (which itself is also
  # a `List`, containing all the remaining elements).
  #
  # This is a singly linked list. Prepending to the list with {List#add} runs
  # in constant time. Traversing the list from front to back is efficient,
  # however, indexed access runs in linear time because the list needs to be
  # traversed to find the element.
  #
  module List
    include Enumerable

    # @private
    CADR = /^c([ad]+)r$/

    # Create a new `List` populated with the given items.
    #
    # @example
    #   list = Hamster::List[:a, :b, :c]
    #   # => Hamster::List[:a, :b, :c]
    #
    # @return [List]
    def self.[](*items)
      from_enum(items)
    end

    # Return an empty `List`.
    #
    # @return [List]
    def self.empty
      EmptyList
    end

    # This method exists distinct from `.[]` since it is ~30% faster
    # than splatting the argument.
    #
    # Marking as private only because it was introduced for an internal
    # refactoring. It could potentially be made public with a good name.
    #
    # @private
    def self.from_enum(items)
      # use destructive operations to build up a new list, like Common Lisp's NCONC
      # this is a very fast way to build up a linked list
      list = tail = Hamster::Cons.allocate
      items.each do |item|
        new_node = Hamster::Cons.allocate
        new_node.instance_variable_set(:@head, item)
        tail.instance_variable_set(:@tail, new_node)
        tail = new_node
      end
      tail.instance_variable_set(:@tail, Hamster::EmptyList)
      list.tail
    end

    # Return the number of items in this `List`.
    # @return [Integer]
    def size
      result, list = 0, self
      until list.empty?
        if list.cached_size?
          return result + list.size
        else
          result += 1
        end
        list = list.tail
      end
      result
    end
    alias :length :size

    # Create a new `List` with `item` added at the front. This is a constant
    # time operation.
    #
    # @example
    #   Hamster::List[:b, :c].add(:a)
    #   # => Hamster::List[:a, :b, :c]
    #
    # @param item [Object] The item to add
    # @return [List]
    def add(item)
      Cons.new(item, self)
    end
    alias :cons :add

    # Create a new `List` with `item` added at the end. This is much less efficient
    # than adding items at the front.
    #
    # @example
    #   Hamster::List[:a, :b] << :c
    #   # => Hamster::List[:a, :b, :c]
    #
    # @param item [Object] The item to add
    # @return [List]
    def <<(item)
      append(List[item])
    end

    # Call the given block once for each item in the list, passing each
    # item from first to last successively to the block. If no block is given,
    # returns an `Enumerator`.
    #
    # @return [self]
    # @yield [item]
    def each
      return to_enum unless block_given?
      list = self
      until list.empty?
        yield(list.head)
        list = list.tail
      end
    end

    # Return a `List` in which each element is derived from the corresponding
    # element in this `List`, transformed through the given block. If no block
    # is given, returns an `Enumerator`.
    #
    # @example
    #   Hamster::List[3, 2, 1].map { |e| e * e } # => Hamster::List[9, 4, 1]
    #
    # @return [List, Enumerator]
    # @yield [item]
    def map(&block)
      return enum_for(:map) unless block_given?
      LazyList.new do
        next self if empty?
        Cons.new(yield(head), tail.map(&block))
      end
    end
    alias :collect :map

    # Return a `List` which is realized by transforming each item into a `List`,
    # and flattening the resulting lists.
    #
    # @example
    #   Hamster::List[1, 2, 3].flat_map { |x| Hamster::List[x, 100] }
    #   # => Hamster::List[1, 100, 2, 100, 3, 100]
    #
    # @return [List]
    def flat_map(&block)
      return enum_for(:flat_map) unless block_given?
      LazyList.new do
        next self if empty?
        head_list = List.from_enum(yield(head))
        next tail.flat_map(&block) if head_list.empty?
        Cons.new(head_list.first, head_list.drop(1).append(tail.flat_map(&block)))
      end
    end

    # Return a `List` which contains all the items for which the given block
    # returns true.
    #
    # @example
    #   Hamster::List["Bird", "Cow", "Elephant"].select { |e| e.size >= 4 }
    #   # => Hamster::List["Bird", "Elephant"]
    #
    # @return [List]
    # @yield [item] Once for each item.
    def select(&block)
      return enum_for(:select) unless block_given?
      LazyList.new do
        list = self
        while true
          break list if list.empty?
          break Cons.new(list.head, list.tail.select(&block)) if yield(list.head)
          list = list.tail
        end
      end
    end
    alias :find_all :select
    alias :keep_if  :select

    # Return a `List` which contains all elements up to, but not including, the
    # first element for which the block returns `nil` or `false`.
    #
    # @example
    #   Hamster::List[1, 3, 5, 7, 6, 4, 2].take_while { |e| e < 5 }
    #   # => Hamster::List[1, 3]
    #
    # @return [List, Enumerator]
    # @yield [item]
    def take_while(&block)
      return enum_for(:take_while) unless block_given?
      LazyList.new do
        next self if empty?
        next Cons.new(head, tail.take_while(&block)) if yield(head)
        EmptyList
      end
    end

    # Return a `List` which contains all elements starting from the
    # first element for which the block returns `nil` or `false`.
    #
    # @example
    #   Hamster::List[1, 3, 5, 7, 6, 4, 2].drop_while { |e| e < 5 }
    #   # => Hamster::List[5, 7, 6, 4, 2]
    #
    # @return [List, Enumerator]
    # @yield [item]
    def drop_while(&block)
      return enum_for(:drop_while) unless block_given?
      LazyList.new do
        list = self
        list = list.tail while !list.empty? && yield(list.head)
        list
      end
    end

    # Return a `List` containing the first `number` items from this `List`.
    #
    # @example
    #   Hamster::List[1, 3, 5, 7, 6, 4, 2].take(3)
    #   # => Hamster::List[1, 3, 5]
    #
    # @param number [Integer] The number of items to retain
    # @return [List]
    def take(number)
      LazyList.new do
        next self if empty?
        next Cons.new(head, tail.take(number - 1)) if number > 0
        EmptyList
      end
    end

    # Return a `List` containing all but the last item from this `List`.
    #
    # @example
    #   Hamster::List["A", "B", "C"].pop  # => Hamster::List["A", "B"]
    #
    # @return [List]
    def pop
      LazyList.new do
        next self if empty?
        new_size = size - 1
        next Cons.new(head, tail.take(new_size - 1)) if new_size >= 1
        EmptyList
      end
    end

    # Return a `List` containing all items after the first `number` items from
    # this `List`.
    #
    # @example
    #   Hamster::List[1, 3, 5, 7, 6, 4, 2].drop(3)
    #   # => Hamster::List[7, 6, 4, 2]
    #
    # @param number [Integer] The number of items to skip over
    # @return [List]
    def drop(number)
      LazyList.new do
        list = self
        while !list.empty? && number > 0
          number -= 1
          list = list.tail
        end
        list
      end
    end

    # Return a `List` with all items from this `List`, followed by all items from
    # `other`.
    #
    # @example
    #   Hamster::List[1, 2, 3].append(Hamster::List[4, 5])
    #   # => Hamster::List[1, 2, 3, 4, 5]
    #
    # @param other [List] The list to add onto the end of this one
    # @return [List]
    def append(other)
      LazyList.new do
        next other if empty?
        Cons.new(head, tail.append(other))
      end
    end
    alias :concat :append
    alias :+ :append

    # Return a `List` with the same items, but in reverse order.
    #
    # @example
    #   Hamster::List["A", "B", "C"].reverse # => Hamster::List["C", "B", "A"]
    #
    # @return [List]
    def reverse
      LazyList.new { reduce(EmptyList) { |list, item| list.cons(item) }}
    end

    # Combine two lists by "zipping" them together.  The corresponding elements
    # from this `List` and each of `others` (that is, the elements with the
    # same indices) will be gathered into lists.
    #
    # If `others` contains fewer elements than this list, `nil` will be used
    # for padding.
    #
    # @example
    #   Hamster::List["A", "B", "C"].zip(Hamster::List[1, 2, 3])
    #   # => Hamster::List[Hamster::List["A", 1], Hamster::List["B", 2], Hamster::List["C", 3]]
    #
    # @param others [List] The list to zip together with this one
    # @return [List]
    def zip(others)
      LazyList.new do
        next self if empty? && others.empty?
        Cons.new(Cons.new(head, Cons.new(others.head)), tail.zip(others.tail))
      end
    end

    # Gather the first element of each nested list into a new `List`, then the second
    # element of each nested list, then the third, and so on. In other words, if each
    # nested list is a "row", return a `List` of "columns" instead.
    #
    # Although the returned list is lazy, each returned nested list (each "column")
    # is strict. So while each nested list in the input can be infinite, the parent
    # `List` must not be, or trying to realize the first element in the output will
    # cause an infinite loop.
    #
    # @example
    #   # First let's create some infinite lists
    #   list1 = Hamster.iterate(1, &:next)
    #   list2 = Hamster.iterate(2) { |n| n * 2 }
    #   list3 = Hamster.iterate(3) { |n| n * 3 }
    #
    #   # Now we transpose our 3 infinite "rows" into an infinite series of 3-element "columns"
    #   Hamster::List[list1, list2, list3].transpose.take(4)
    #   # => Hamster::List[
    #   #      Hamster::List[1, 2, 3],
    #   #      Hamster::List[2, 4, 9],
    #   #      Hamster::List[3, 8, 27],
    #   #      Hamster::List[4, 16, 81]]
    #
    # @return [List]
    def transpose
      return EmptyList if empty?
      LazyList.new do
        next EmptyList if any? { |list| list.empty? }
        heads, tails = EmptyList, EmptyList
        reverse_each { |list| heads, tails = heads.cons(list.head), tails.cons(list.tail) }
        Cons.new(heads, tails.transpose)
      end
    end

    # Concatenate an infinite series of copies of this `List` together into a
    # new `List`. Or, if empty, just return an empty list.
    #
    # @example
    #   Hamster::List[1, 2, 3].cycle.take(10)
    #   # => Hamster::List[1, 2, 3, 1, 2, 3, 1, 2, 3, 1]
    #
    # @return [List]
    def cycle
      LazyList.new do
        next self if empty?
        Cons.new(head, tail.append(cycle))
      end
    end

    # Return a new `List` with the same elements, but rotated so that the one at
    # index `count` is the first element of the new list. If `count` is positive,
    # the elements will be shifted left, and those shifted past the lowest position
    # will be moved to the end. If `count` is negative, the elements will be shifted
    # right, and those shifted past the last position will be moved to the beginning.
    #
    # @example
    #   l = Hamster::List["A", "B", "C", "D", "E", "F"]
    #   l.rotate(2)   # => Hamster::List["C", "D", "E", "F", "A", "B"]
    #   l.rotate(-1)  # => Hamster::List["F", "A", "B", "C", "D", "E"]
    #
    # @param count [Integer] The number of positions to shift items by
    # @return [Vector]
    # @raise [TypeError] if count is not an integer.
    def rotate(count = 1)
      raise TypeError, "expected Integer" if not count.is_a?(Integer)
      return self if empty? || (count % size) == 0
      count = (count >= 0) ? count % size : (size - (~count % size) - 1)
      drop(count).append(take(count))
    end

    # Return two `List`s, one of the first `number` items, and another with the
    # remaining.
    #
    # @example
    #   Hamster::List["a", "b", "c", "d"].split_at(2)
    #   # => [Hamster::List["a", "b"], Hamster::List["c", "d"]]
    #
    # @param number [Integer] The index at which to split this list
    # @return [Array]
    def split_at(number)
      [take(number), drop(number)].freeze
    end

    # Return two `List`s, one up to (but not including) the first item for which the
    # block returns `nil` or `false`, and another of all the remaining items.
    #
    # @example
    #   Hamster::List[4, 3, 5, 2, 1].span { |x| x > 2 }
    #   # => [Hamster::List[4, 3, 5], Hamster::List[2, 1]]
    #
    # @return [Array]
    # @yield [item]
    def span(&block)
      return [self, EmptyList].freeze unless block_given?
      splitter = Splitter.new(self, block)
      mutex = Mutex.new
      [Splitter::Left.new(splitter, splitter.left, mutex),
       Splitter::Right.new(splitter, mutex)].freeze
    end

    # Return two `List`s, one up to (but not including) the first item for which the
    # block returns true, and another of all the remaining items.
    #
    # @example
    #   Hamster::List[1, 3, 4, 2, 5].break { |x| x > 3 }
    #   # => [Hamster::List[1, 3], Hamster::List[4, 2, 5]]
    #
    # @return [Array]
    # @yield [item]
    def break(&block)
      return span unless block_given?
      span { |item| !yield(item) }
    end

    # Return an empty `List`. If used on a subclass, returns an empty instance
    # of that class.
    #
    # @return [List]
    def clear
      EmptyList
    end

    # Return a new `List` with the same items, but sorted.
    #
    # @overload sort
    #   Compare elements with their natural sort key (`#<=>`).
    #
    #   @example
    #     Hamster::List["Elephant", "Dog", "Lion"].sort
    #     # => Hamster::List["Dog", "Elephant", "Lion"]
    #
    # @overload sort
    #   Uses the block as a comparator to determine sorted order.
    #
    #   @yield [a, b] Any number of times with different pairs of elements.
    #   @yieldreturn [Integer] Negative if the first element should be sorted
    #                          lower, positive if the latter element, or 0 if
    #                          equal.
    #   @example
    #     Hamster::List["Elephant", "Dog", "Lion"].sort { |a,b| a.size <=> b.size }
    #     # => Hamster::List["Dog", "Lion", "Elephant"]
    #
    # @return [List]
    def sort(&comparator)
      LazyList.new { List.from_enum(super(&comparator)) }
    end

    # Return a new `List` with the same items, but sorted. The sort order is
    # determined by mapping the items through the given block to obtain sort
    # keys, and then sorting the keys according to their natural sort order
    # (`#<=>`).
    #
    # @yield [element] Once for each element.
    # @yieldreturn a sort key object for the yielded element.
    # @example
    #   Hamster::List["Elephant", "Dog", "Lion"].sort_by { |e| e.size }
    #   # => Hamster::List["Dog", "Lion", "Elephant"]
    #
    # @return [List]
    def sort_by(&transformer)
      return sort unless block_given?
      LazyList.new { List.from_enum(super(&transformer)) }
    end

    # Return a new `List` with `sep` inserted between each of the existing elements.
    #
    # @example
    #   Hamster::List["one", "two", "three"].intersperse(" ")
    #   # => Hamster::List["one", " ", "two", " ", "three"]
    #
    # @return [List]
    def intersperse(sep)
      LazyList.new do
        next self if tail.empty?
        Cons.new(head, Cons.new(sep, tail.intersperse(sep)))
      end
    end

    # Return a `List` with the same items, but all duplicates removed.
    # Use `#hash` and `#eql?` to determine which items are duplicates.
    #
    # @example
    #   Hamster::List[:a, :b, :a, :c, :b].uniq      # => Hamster::List[:a, :b, :c]
    #   Hamster::List["a", "A", "b"].uniq(&:upcase) # => Hamster::List["a", "b"]
    #
    # @return [List]
    def uniq(&block)
      _uniq(::Set.new, &block)
    end

    # @private
    # Separate from `uniq` so as not to expose `items` in the public API.
    def _uniq(items, &block)
      if block_given?
        LazyList.new do
          next self if empty?
          if items.add?(block.call(head))
            Cons.new(head, tail._uniq(items, &block))
          else
            tail._uniq(items, &block)
          end
        end
      else
        LazyList.new do
          next self if empty?
          next tail._uniq(items) if items.include?(head)
          Cons.new(head, tail._uniq(items.add(head)))
        end
      end
    end
    protected :_uniq

    # Return a `List` with all the elements from both this list and `other`,
    # with all duplicates removed.
    #
    # @example
    #   Hamster::List[1, 2].union(Hamster::List[2, 3]) # => Hamster::List[1, 2, 3]
    #
    # @param other [List] The list to merge with
    # @return [List]
    def union(other, items = ::Set.new)
      LazyList.new do
        next other._uniq(items) if empty?
        next tail.union(other, items) if items.include?(head)
        Cons.new(head, tail.union(other, items.add(head)))
      end
    end
    alias :| :union

    # Return a `List` with all elements except the last one.
    #
    # @example
    #   Hamster::List["a", "b", "c"].init # => Hamster::List["a", "b"]
    #
    # @return [List]
    def init
      return EmptyList if tail.empty?
      LazyList.new { Cons.new(head, tail.init) }
    end

    # Return the last item in this list.
    # @return [Object]
    def last
      list = self
      list = list.tail until list.tail.empty?
      list.head
    end

    # Return a `List` of all suffixes of this list.
    #
    # @example
    #   Hamster::List[1,2,3].tails
    #   # => Hamster::List[
    #   #      Hamster::List[1, 2, 3],
    #   #      Hamster::List[2, 3],
    #   #      Hamster::List[3]]
    #
    # @return [List]
    def tails
      LazyList.new do
        next self if empty?
        Cons.new(self, tail.tails)
      end
    end

    # Return a `List` of all prefixes of this list.
    #
    # @example
    #   Hamster::List[1,2,3].inits
    #   # => Hamster::List[
    #   #      Hamster::List[1],
    #   #      Hamster::List[1, 2],
    #   #      Hamster::List[1, 2, 3]]
    #
    # @return [List]
    def inits
      LazyList.new do
        next self if empty?
        Cons.new(List[head], tail.inits.map { |list| list.cons(head) })
      end
    end

    # Return a `List` of all combinations of length `n` of items from this `List`.
    #
    # @example
    #   Hamster::List[1,2,3].combination(2)
    #   # => Hamster::List[
    #   #      Hamster::List[1, 2],
    #   #      Hamster::List[1, 3],
    #   #      Hamster::List[2, 3]]
    #
    # @return [List]
    def combination(n)
      return Cons.new(EmptyList) if n == 0
      LazyList.new do
        next self if empty?
        tail.combination(n - 1).map { |list| list.cons(head) }.append(tail.combination(n))
      end
    end

    # Split the items in this list in groups of `number`. Return a list of lists.
    #
    # @example
    #   ("a".."o").to_list.chunk(5)
    #   # => Hamster::List[
    #   #      Hamster::List["a", "b", "c", "d", "e"],
    #   #      Hamster::List["f", "g", "h", "i", "j"],
    #   #      Hamster::List["k", "l", "m", "n", "o"]]
    #
    # @return [List]
    def chunk(number)
      LazyList.new do
        next self if empty?
        first, remainder = split_at(number)
        Cons.new(first, remainder.chunk(number))
      end
    end

    # Split the items in this list in groups of `number`, and yield each group
    # to the block (as a `List`). If no block is given, returns an
    # `Enumerator`.
    #
    # @return [self, Enumerator]
    # @yield [list] Once for each chunk.
    def each_chunk(number, &block)
      return enum_for(:each_chunk, number) unless block_given?
      chunk(number).each(&block)
      self
    end
    alias :each_slice :each_chunk

    # Return a new `List` with all nested lists recursively "flattened out",
    # that is, their elements inserted into the new `List` in the place where
    # the nested list originally was.
    #
    # @example
    #   Hamster::List[Hamster::List[1, 2], Hamster::List[3, 4]].flatten
    #   # => Hamster::List[1, 2, 3, 4]
    #
    # @return [List]
    def flatten
      LazyList.new do
        next self if empty?
        next head.append(tail.flatten) if head.is_a?(List)
        Cons.new(head, tail.flatten)
      end
    end

    # Passes each item to the block, and gathers them into a {Hash} where the
    # keys are return values from the block, and the values are `List`s of items
    # for which the block returned that value.
    #
    # @return [Hash]
    # @yield [item]
    # @example
    #    Hamster::List["a", "b", "ab"].group_by { |e| e.size }
    #    # Hamster::Hash[
    #    #   1 => Hamster::List["b", "a"],
    #    #   2 => Hamster::List["ab"]
    #    # ]
    def group_by(&block)
      group_by_with(EmptyList, &block)
    end
    alias :group :group_by

    # Retrieve the item at `index`. Negative indices count back from the end of
    # the list (-1 is the last item). If `index` is invalid (either too high or
    # too low), return `nil`.
    #
    # @param index [Integer] The index to retrieve
    # @return [Object]
    def at(index)
      index += size if index < 0
      return nil if index < 0
      node = self
      while index > 0
        node = node.tail
        index -= 1
      end
      node.head
    end

    # Return specific objects from the `List`. All overloads return `nil` if
    # the starting index is out of range.
    #
    # @overload list.slice(index)
    #   Returns a single object at the given `index`. If `index` is negative,
    #   count backwards from the end.
    #
    #   @param index [Integer] The index to retrieve. May be negative.
    #   @return [Object]
    #   @example
    #     l = Hamster::List["A", "B", "C", "D", "E", "F"]
    #     l[2]  # => "C"
    #     l[-1] # => "F"
    #     l[6]  # => nil
    #
    # @overload list.slice(index, length)
    #   Return a sublist starting at `index` and continuing for `length`
    #   elements or until the end of the `List`, whichever occurs first.
    #
    #   @param start [Integer] The index to start retrieving items from. May be
    #                          negative.
    #   @param length [Integer] The number of items to retrieve.
    #   @return [List]
    #   @example
    #     l = Hamster::List["A", "B", "C", "D", "E", "F"]
    #     l[2, 3]  # => Hamster::List["C", "D", "E"]
    #     l[-2, 3] # => Hamster::List["E", "F"]
    #     l[20, 1] # => nil
    #
    # @overload list.slice(index..end)
    #   Return a sublist starting at `index` and continuing to index
    #   `end` or the end of the `List`, whichever occurs first.
    #
    #   @param range [Range] The range of indices to retrieve.
    #   @return [Vector]
    #   @example
    #     l = Hamster::List["A", "B", "C", "D", "E", "F"]
    #     l[2..3]    # => Hamster::List["C", "D"]
    #     l[-2..100] # => Hamster::List["E", "F"]
    #     l[20..21]  # => nil
    def slice(arg, length = (missing_length = true))
      if missing_length
        if arg.is_a?(Range)
          from, to = arg.begin, arg.end
          from += size if from < 0
          return nil if from < 0
          to   += size if to < 0
          to   += 1    if !arg.exclude_end?
          length = to - from
          length = 0 if length < 0
          list = self
          while from > 0
            return nil if list.empty?
            list = list.tail
            from -= 1
          end
          list.take(length)
        else
          at(arg)
        end
      else
        return nil if length < 0
        arg += size if arg < 0
        return nil if arg < 0
        list = self
        while arg > 0
          return nil if list.empty?
          list = list.tail
          arg -= 1
        end
        list.take(length)
      end
    end
    alias :[] :slice

    # Return a `List` of indices of matching objects.
    #
    # @overload indices(object)
    #   Return a `List` of indices where `object` is found. Use `#==` for
    #   testing equality.
    #
    #   @example
    #     Hamster::List[1, 2, 3, 4].indices(2)
    #     # => Hamster::List[1]
    #
    # @overload indices
    #   Pass each item successively to the block. Return a list of indices
    #   where the block returns true.
    #
    #   @yield [item]
    #   @example
    #     Hamster::List[1, 2, 3, 4].indices { |e| e.even? }
    #     # => Hamster::List[1, 3]
    #
    # @return [List]
    def indices(object = Undefined, i = 0, &block)
      return indices { |item| item == object } if not block_given?
      return EmptyList if empty?
      LazyList.new do
        node = self
        while true
          break Cons.new(i, node.tail.indices(Undefined, i + 1, &block)) if yield(node.head)
          node = node.tail
          break EmptyList if node.empty?
          i += 1
        end
      end
    end

    # Merge all the nested lists into a single list, using the given comparator
    # block to determine the order which items should be shifted out of the nested
    # lists and into the output list.
    #
    # @example
    #   list_1 = Hamster::List[1, -3, -5]
    #   list_2 = Hamster::List[-2, 4, 6]
    #   Hamster::List[list_1, list_2].merge { |a,b| a.abs <=> b.abs }
    #   # => Hamster::List[1, -2, -3, 4, -5, 6]
    #
    # @return [List]
    # @yield [a, b] Pairs of items from matching indices in each list.
    # @yieldreturn [Integer] Negative if the first element should be selected
    #                        first, positive if the latter element, or zero if
    #                        either.
    def merge(&comparator)
      return merge_by unless block_given?
      LazyList.new do
        sorted = reject(&:empty?).sort do |a, b|
          yield(a.head, b.head)
        end
        next EmptyList if sorted.empty?
        Cons.new(sorted.head.head, sorted.tail.cons(sorted.head.tail).merge(&comparator))
      end
    end

    # Merge all the nested lists into a single list, using sort keys generated
    # by mapping the items in the nested lists through the given block to determine the
    # order which items should be shifted out of the nested lists and into the output
    # list. Whichever nested list's `#head` has the "lowest" sort key (according to
    # their natural order) will be the first in the merged `List`.
    #
    # @example
    #   list_1 = Hamster::List[1, -3, -5]
    #   list_2 = Hamster::List[-2, 4, 6]
    #   Hamster::List[list_1, list_2].merge_by { |x| x.abs }
    #   # => Hamster::List[1, -2, -3, 4, -5, 6]
    #
    # @return [List]
    # @yield [item] Once for each item in either list.
    # @yieldreturn [Object] A sort key for the element.
    def merge_by(&transformer)
      return merge_by { |item| item } unless block_given?
      LazyList.new do
        sorted = reject(&:empty?).sort_by do |list|
          yield(list.head)
        end
        next EmptyList if sorted.empty?
        Cons.new(sorted.head.head, sorted.tail.cons(sorted.head.tail).merge_by(&transformer))
      end
    end

    # Return a randomly chosen element from this list.
    # @return [Object]
    def sample
      at(rand(size))
    end

    # Return a new `List` with the given items inserted before the item at `index`.
    #
    # @example
    #   Hamster::List["A", "D", "E"].insert(1, "B", "C") # => Hamster::List["A", "B", "C", "D", "E"]
    #
    # @param index [Integer] The index where the new items should go
    # @param items [Array] The items to add
    # @return [List]
    def insert(index, *items)
      if index == 0
        return List.from_enum(items).append(self)
      elsif index > 0
        LazyList.new do
          Cons.new(head, tail.insert(index-1, *items))
        end
      else
        raise IndexError if index < -size
        insert(index + size, *items)
      end
    end

    # Return a `List` with all elements equal to `obj` removed. `#==` is used
    # for testing equality.
    #
    # @example
    #   Hamster::List[:a, :b, :a, :a, :c].delete(:a) # => Hamster::List[:b, :c]
    #
    # @param obj [Object] The object to remove.
    # @return [List]
    def delete(obj)
      list = self
      list = list.tail while list.head == obj && !list.empty?
      return EmptyList if list.empty?
      LazyList.new { Cons.new(list.head, list.tail.delete(obj)) }
    end

    # Return a `List` containing the same items, minus the one at `index`.
    # If `index` is negative, it counts back from the end of the list.
    #
    # @example
    #   Hamster::List[1, 2, 3].delete_at(1)  # => Hamster::List[1, 3]
    #   Hamster::List[1, 2, 3].delete_at(-1) # => Hamster::List[1, 2]
    #
    # @param index [Integer] The index of the item to remove
    # @return [List]
    def delete_at(index)
      if index == 0
        tail
      elsif index < 0
        index += size if index < 0
        return self if index < 0
        delete_at(index)
      else
        LazyList.new { Cons.new(head, tail.delete_at(index - 1)) }
      end
    end

    # Replace a range of indexes with the given object.
    #
    # @overload fill(object)
    #   Return a new `List` of the same size, with every index set to `object`.
    #
    #   @param [Object] object Fill value.
    #   @example
    #     Hamster::List["A", "B", "C", "D", "E", "F"].fill("Z")
    #     # => Hamster::List["Z", "Z", "Z", "Z", "Z", "Z"]
    #
    # @overload fill(object, index)
    #   Return a new `List` with all indexes from `index` to the end of the
    #   vector set to `obj`.
    #
    #   @param [Object] object Fill value.
    #   @param [Integer] index Starting index. May be negative.
    #   @example
    #     Hamster::List["A", "B", "C", "D", "E", "F"].fill("Z", 3)
    #     # => Hamster::List["A", "B", "C", "Z", "Z", "Z"]
    #
    # @overload fill(object, index, length)
    #   Return a new `List` with `length` indexes, beginning from `index`,
    #   set to `obj`. Expands the `List` if `length` would extend beyond the
    #   current length.
    #
    #   @param [Object] object Fill value.
    #   @param [Integer] index Starting index. May be negative.
    #   @param [Integer] length
    #   @example
    #     Hamster::List["A", "B", "C", "D", "E", "F"].fill("Z", 3, 2)
    #     # => Hamster::List["A", "B", "C", "Z", "Z", "F"]
    #     Hamster::List["A", "B"].fill("Z", 1, 5)
    #     # => Hamster::List["A", "Z", "Z", "Z", "Z", "Z"]
    #
    # @return [List]
    # @raise [IndexError] if index is out of negative range.
    def fill(obj, index = 0, length = nil)
      if index == 0
        length ||= size
        if length > 0
          LazyList.new do
            Cons.new(obj, tail.fill(obj, 0, length-1))
          end
        else
          self
        end
      elsif index > 0
        LazyList.new do
          Cons.new(head, tail.fill(obj, index-1, length))
        end
      else
        raise IndexError if index < -size
        fill(obj, index + size, length)
      end
    end

    # Yields all permutations of length `n` of the items in the list, and then
    # returns `self`. If no length `n` is specified, permutations of the entire
    # list will be yielded.
    #
    # There is no guarantee about which order the permutations will be yielded in.
    #
    # If no block is given, an `Enumerator` is returned instead.
    #
    # @example
    #   Hamster::List[1, 2, 3].permutation.to_a
    #   # => [Hamster::List[1, 2, 3],
    #   #     Hamster::List[2, 1, 3],
    #   #     Hamster::List[2, 3, 1],
    #   #     Hamster::List[1, 3, 2],
    #   #     Hamster::List[3, 1, 2],
    #   #     Hamster::List[3, 2, 1]]
    #
    # @return [self, Enumerator]
    # @yield [list] Once for each permutation.
    def permutation(length = size, &block)
      return enum_for(:permutation, length) if not block_given?
      if length == 0
        yield EmptyList
      elsif length == 1
        each { |obj| yield Cons.new(obj, EmptyList) }
      elsif not empty?
        if length < size
          tail.permutation(length, &block)
        end

        tail.permutation(length-1) do |p|
          0.upto(length-1) do |i|
            left,right = p.split_at(i)
            yield left.append(right.cons(head))
          end
        end
      end
      self
    end

    # Yield every non-empty sublist to the given block. (The entire `List` also
    # counts as one sublist.)
    #
    # @example
    #   Hamster::List[1, 2, 3].subsequences { |list| p list }
    #   # prints:
    #   # Hamster::List[1]
    #   # Hamster::List[1, 2]
    #   # Hamster::List[1, 2, 3]
    #   # Hamster::List[2]
    #   # Hamster::List[2, 3]
    #   # Hamster::List[3]
    #
    # @yield [sublist] One or more contiguous elements from this list
    # @return [self]
    def subsequences(&block)
      return enum_for(:subsequences) if not block_given?
      if not empty?
        1.upto(size) do |n|
          yield take(n)
        end
        tail.subsequences(&block)
      end
      self
    end

    # Return two `List`s, the first containing all the elements for which the
    # block evaluates to true, the second containing the rest.
    #
    # @example
    #   Hamster::List[1, 2, 3, 4, 5, 6].partition { |x| x.even? }
    #   # => [Hamster::List[2, 4, 6], Hamster::List[1, 3, 5]]
    #
    # @return [List]
    # @yield [item] Once for each item.
    def partition(&block)
      return enum_for(:partition) if not block_given?
      partitioner = Partitioner.new(self, block)
      mutex = Mutex.new
      [Partitioned.new(partitioner, partitioner.left, mutex),
       Partitioned.new(partitioner, partitioner.right, mutex)].freeze
    end

    # Return true if `other` has the same type and contents as this `Hash`.
    #
    # @param other [Object] The collection to compare with
    # @return [Boolean]
    def eql?(other)
      list = self
      loop do
        return true if other.equal?(list)
        return false unless other.is_a?(List)
        return other.empty? if list.empty?
        return false if other.empty?
        return false unless other.head.eql?(list.head)
        list = list.tail
        other = other.tail
      end
    end

    # See `Object#hash`
    # @return [Integer]
    def hash
      reduce(0) { |hash, item| (hash << 5) - hash + item.hash }
    end

    # Return `self`. Since this is an immutable object duplicates are
    # equivalent.
    # @return [List]
    def dup
      self
    end
    alias :clone :dup

    # Return `self`.
    # @return [List]
    def to_list
      self
    end

    # Return the contents of this `List` as a programmer-readable `String`. If all the
    # items in the list are serializable as Ruby literal strings, the returned string can
    # be passed to `eval` to reconstitute an equivalent `List`.
    #
    # @return [String]
    def inspect
      result = "Hamster::List["
      each_with_index { |obj, i| result << ', ' if i > 0; result << obj.inspect }
      result << "]"
    end

    # Allows this `List` to be printed at the `pry` console, or using `pp` (from the
    # Ruby standard library), in a way which takes the amount of horizontal space on
    # the screen into account, and which indents nested structures to make them easier
    # to read.
    #
    # @private
    def pretty_print(pp)
      pp.group(1, "Hamster::List[", "]") do
        pp.breakable ''
        pp.seplist(self) { |obj| obj.pretty_print(pp) }
      end
    end

    # @private
    def respond_to?(name, include_private = false)
      super || !!name.to_s.match(CADR)
    end

    # Return `true` if the size of this list can be obtained in constant time (without
    # traversing the list).
    # @return [Integer]
    def cached_size?
      false
    end

    private

    # Perform compositions of `car` and `cdr` operations (traditional shorthand
    # for `head` and `tail` respectively). Their names consist of a `c`,
    # followed by at least one `a` or `d`, and finally an `r`. The series of
    # `a`s and `d`s in the method name identify the series of `car` and `cdr`
    # operations performed, in inverse order.
    #
    # @return [Object, List]
    # @example
    #   l = Hamster::List[nil, Hamster::List[1]]
    #   l.car   # => nil
    #   l.cdr   # => Hamster::List[Hamster::List[1]]
    #   l.cadr  # => Hamster::List[1]
    #   l.caadr # => 1
    def method_missing(name, *args, &block)
      if name.to_s.match(CADR)
        code = "def #{name}; self."
        code << Regexp.last_match[1].reverse.chars.map do |char|
          {'a' => 'head', 'd' => 'tail'}[char]
        end.join('.')
        code << '; end'
        List.class_eval(code)
        send(name, *args, &block)
      else
        super
      end
    end
  end

  # The basic building block for constructing lists
  #
  # A Cons, also known as a "cons cell", has a "head" and a "tail", where
  # the head is an element in the list, and the tail is a reference to the
  # rest of the list. This way a singly linked list can be constructed, with
  # each `Cons` holding a single element and a pointer to the next
  # `Cons`.
  #
  # The last `Cons` instance in the chain has the {EmptyList} as its tail.
  #
  # @private
  class Cons
    include List

    attr_reader :head, :tail

    def initialize(head, tail = EmptyList)
      @head = head
      @tail = tail
      @size = tail.cached_size? ? tail.size + 1 : nil
    end

    def empty?
      false
    end

    def size
      @size ||= super
    end
    alias :length :size

    def cached_size?
      @size != nil
    end
  end

  # A `LazyList` takes a block that returns a `List`, i.e. an object that responds
  # to `#head`, `#tail` and `#empty?`. The list is only realized (i.e. the block is
  # only called) when one of these operations is performed.
  #
  # By returning a `Cons` that in turn has a {LazyList} as its tail, one can
  # construct infinite `List`s.
  #
  # @private
  class LazyList
    include List

    def initialize(&block)
      @head   = block # doubles as storage for block while yet unrealized
      @tail   = nil
      @atomic = Concurrent::AtomicReference.new(0) # haven't yet run block
      @size   = nil
    end

    def head
      realize if @atomic.get != 2
      @head
    end
    alias :first :head

    def tail
      realize if @atomic.get != 2
      @tail
    end

    def empty?
      realize if @atomic.get != 2
      @size == 0
    end

    def size
      @size ||= super
    end
    alias :length :size

    def cached_size?
      @size != nil
    end

    private

    QUEUE = ConditionVariable.new
    MUTEX = Mutex.new

    def realize
      while true
        # try to "claim" the right to run the block which realizes target
        if @atomic.compare_and_swap(0,1) # full memory barrier here
          begin
            list = @head.call
            if list.empty?
              @head, @tail, @size = nil, self, 0
            else
              @head, @tail = list.head, list.tail
            end
          rescue
            @atomic.set(0)
            MUTEX.synchronize { QUEUE.broadcast }
            raise
          end
          @atomic.set(2)
          MUTEX.synchronize { QUEUE.broadcast }
          return
        end
        # we failed to "claim" it, another thread must be running it
        if @atomic.get == 1 # another thread is running the block
          MUTEX.synchronize do
            # check value of @atomic again, in case another thread already changed it
            #   *and* went past the call to QUEUE.broadcast before we got here
            QUEUE.wait(MUTEX) if @atomic.get == 1
          end
        elsif @atomic.get == 2 # another thread finished the block
          return
        end
      end
    end
  end

  # Common behavior for other classes which implement various kinds of `List`s
  # @private
  class Realizable
    include List

    def initialize
      @head, @tail, @size = Undefined, Undefined, nil
    end

    def head
      realize if @head == Undefined
      @head
    end
    alias :first :head

    def tail
      realize if @tail == Undefined
      @tail
    end

    def empty?
      realize if @head == Undefined
      @size == 0
    end

    def size
      @size ||= super
    end
    alias :length :size

    def cached_size?
      @size != nil
    end

    def realized?
      @head != Undefined
    end
  end

  # This class can divide a collection into 2 `List`s, one of items
  #   for which the block returns true, and another for false
  # At the same time, it guarantees the block will only be called ONCE for each item
  #
  # @private
  class Partitioner
    attr_reader :left, :right
    def initialize(list, block)
      @list, @block, @left, @right = list, block, [], []
    end

    def next_item
      unless @list.empty?
        item = @list.head
        (@block.call(item) ? @left : @right) << item
        @list = @list.tail
      end
    end

    def done?
      @list.empty?
    end
  end

  # One of the `List`s which gets its items from a Partitioner
  # @private
  class Partitioned < Realizable
    def initialize(partitioner, buffer, mutex)
      super()
      @partitioner, @buffer, @mutex = partitioner, buffer, mutex
    end

    def realize
      # another thread may get ahead of us and null out @mutex
      mutex = @mutex
      mutex && mutex.synchronize do
        return if @head != Undefined # another thread got ahead of us
        while true
          if !@buffer.empty?
            @head = @buffer.shift
            @tail = Partitioned.new(@partitioner, @buffer, @mutex)
            # don't hold onto references
            # tail will keep references alive until end of list is reached
            @partitioner, @buffer, @mutex = nil, nil, nil
            return
          elsif @partitioner.done?
            @head, @size, @tail = nil, 0, self
            @partitioner, @buffer, @mutex = nil, nil, nil # allow them to be GC'd
            return
          else
            @partitioner.next_item
          end
        end
      end
    end
  end

  # This class can divide a list up into 2 `List`s, one for the prefix of
  # elements for which the block returns true, and another for all the elements
  # after that. It guarantees that the block will only be called ONCE for each
  # item
  #
  # @private
  class Splitter
    attr_reader :left, :right
    def initialize(list, block)
      @list, @block, @left, @right = list, block, [], EmptyList
    end

    def next_item
      unless @list.empty?
        item = @list.head
        if @block.call(item)
          @left << item
          @list = @list.tail
        else
          @right = @list
          @list  = EmptyList
        end
      end
    end

    def done?
      @list.empty?
    end

    # @private
    class Left < Realizable
      def initialize(splitter, buffer, mutex)
        super()
        @splitter, @buffer, @mutex = splitter, buffer, mutex
      end

      def realize
        # another thread may get ahead of us and null out @mutex
        mutex = @mutex
        mutex && mutex.synchronize do
          return if @head != Undefined # another thread got ahead of us
          while true
            if !@buffer.empty?
              @head = @buffer.shift
              @tail = Left.new(@splitter, @buffer, @mutex)
              @splitter, @buffer, @mutex = nil, nil, nil
              return
            elsif @splitter.done?
              @head, @size, @tail = nil, 0, self
              @splitter, @buffer, @mutex = nil, nil, nil
              return
            else
              @splitter.next_item
            end
          end
        end
      end
    end

    # @private
    class Right < Realizable
      def initialize(splitter, mutex)
        super()
        @splitter, @mutex = splitter, mutex
      end

      def realize
        mutex = @mutex
        mutex && mutex.synchronize do
          return if @head != Undefined
          @splitter.next_item until @splitter.done?
          if @splitter.right.empty?
            @head, @size, @tail = nil, 0, self
          else
            @head, @tail = @splitter.right.head, @splitter.right.tail
          end
          @splitter, @mutex = nil, nil
        end
      end
    end
  end

  # A list without any elements. This is a singleton, since all empty lists are equivalent.
  # @private
  module EmptyList
    class << self
      include List

      # There is no first item in an empty list, so return `nil`.
      # @return [nil]
      def head
        nil
      end
      alias :first :head

      # There are no subsequent elements, so return an empty list.
      # @return [self]
      def tail
        self
      end

      def empty?
        true
      end

      # Return the number of items in this `List`.
      # @return [Integer]
      def size
        0
      end
      alias :length :size

      def cached_size?
        true
      end
    end
  end.freeze
end
