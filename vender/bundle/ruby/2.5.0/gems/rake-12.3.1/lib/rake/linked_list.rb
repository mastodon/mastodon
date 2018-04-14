# frozen_string_literal: true
module Rake

  # Polylithic linked list structure used to implement several data
  # structures in Rake.
  class LinkedList
    include Enumerable
    attr_reader :head, :tail

    # Polymorphically add a new element to the head of a list. The
    # type of head node will be the same list type as the tail.
    def conj(item)
      self.class.cons(item, self)
    end

    # Is the list empty?
    # .make guards against a list being empty making any instantiated LinkedList
    # object not empty by default
    # You should consider overriding this method if you implement your own .make method
    def empty?
      false
    end

    # Lists are structurally equivalent.
    def ==(other)
      current = self
      while !current.empty? && !other.empty?
        return false if current.head != other.head
        current = current.tail
        other = other.tail
      end
      current.empty? && other.empty?
    end

    # Convert to string: LL(item, item...)
    def to_s
      items = map(&:to_s).join(", ")
      "LL(#{items})"
    end

    # Same as +to_s+, but with inspected items.
    def inspect
      items = map(&:inspect).join(", ")
      "LL(#{items})"
    end

    # For each item in the list.
    def each
      current = self
      while !current.empty?
        yield(current.head)
        current = current.tail
      end
      self
    end

    # Make a list out of the given arguments. This method is
    # polymorphic
    def self.make(*args)
      # return an EmptyLinkedList if there are no arguments
      return empty if !args || args.empty?

      # build a LinkedList by starting at the tail and iterating
      # through each argument
      # inject takes an EmptyLinkedList to start
      args.reverse.inject(empty) do |list, item|
        list = cons(item, list)
        list # return the newly created list for each item in the block
      end
    end

    # Cons a new head onto the tail list.
    def self.cons(head, tail)
      new(head, tail)
    end

    # The standard empty list class for the given LinkedList class.
    def self.empty
      self::EMPTY
    end

    protected

    def initialize(head, tail=EMPTY)
      @head = head
      @tail = tail
    end

    # Represent an empty list, using the Null Object Pattern.
    #
    # When inheriting from the LinkedList class, you should implement
    # a type specific Empty class as well. Make sure you set the class
    # instance variable @parent to the associated list class (this
    # allows conj, cons and make to work polymorphically).
    class EmptyLinkedList < LinkedList
      @parent = LinkedList

      def initialize
      end

      def empty?
        true
      end

      def self.cons(head, tail)
        @parent.cons(head, tail)
      end
    end

    EMPTY = EmptyLinkedList.new
  end
end
