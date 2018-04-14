require "set"
require "hamster/hash"
require "hamster/set"
require "hamster/vector"
require "hamster/sorted_set"
require "hamster/list"
require "hamster/deque"
require "hamster/core_ext/struct"

module Hamster
  class << self

    # Create a Hamster immutable data structure with nested Hamster data
    # structure from a nested Ruby object `obj`.  This method recursively
    # "walks" the Ruby object, converting Ruby `Hash` to {Hamster::Hash}, Ruby
    # `Array` to {Hamster::Vector}, Ruby `Set` to {Hamster::Set}, and Ruby
    # `SortedSet` to {Hamster::SortedSet}.  Other objects are left as-is.
    #
    # @example
    #   h = Hamster.from({ "a" => [1, 2], "b" => "c" })
    #   # => Hamster::Hash["a" => Hamster::Vector[1, 2], "b" => "c"]
    #
    # @return [Hash, Vector, Set, SortedSet, Object]
    def from(obj)
      case obj
      when ::Hash
        res = obj.map { |key, value| [from(key), from(value)] }
        Hamster::Hash.new(res)
      when Hamster::Hash
        obj.map { |key, value| [from(key), from(value)] }
      when ::Struct
        from(obj.to_h)
      when ::Array
        res = obj.map { |element| from(element) }
        Hamster::Vector.new(res)
      when ::SortedSet
        # This clause must go before ::Set clause, since ::SortedSet is a ::Set.
        res = obj.map { |element| from(element) }
        Hamster::SortedSet.new(res)
      when ::Set
        res = obj.map { |element| from(element) }
        Hamster::Set.new(res)
      when Hamster::Vector, Hamster::Set, Hamster::SortedSet
        obj.map { |element| from(element) }
      else
        obj
      end
    end

    # Create a Ruby object from Hamster data. This method recursively "walks"
    # the Hamster object, converting {Hamster::Hash} to Ruby `Hash`,
    # {Hamster::Vector} and {Hamster::Deque} to Ruby `Array`, {Hamster::Set}
    # to Ruby `Set`, and {Hamster::SortedSet} to Ruby `SortedSet`.  Other
    # objects are left as-is.
    #
    # @example
    #   h = Hamster.to_ruby(Hamster.from({ "a" => [1, 2], "b" => "c" }))
    #   # => { "a" => [1, 2], "b" => "c" }
    #
    # @return [::Hash, ::Array, ::Set, ::SortedSet, Object]
    def to_ruby(obj)
      case obj
      when Hamster::Hash, ::Hash
        obj.each_with_object({}) { |keyval, hash| hash[to_ruby(keyval[0])] = to_ruby(keyval[1]) }
      when Hamster::Vector, ::Array
        obj.each_with_object([]) { |element, arr| arr << to_ruby(element) }
      when Hamster::Set, ::Set
        obj.each_with_object(::Set.new) { |element, set| set << to_ruby(element) }
      when Hamster::SortedSet, ::SortedSet
        obj.each_with_object(::SortedSet.new) { |element, set| set << to_ruby(element) }
      when Hamster::Deque
        obj.to_a.tap { |arr| arr.map! { |element| to_ruby(element) }}
      else
        obj
      end
    end
  end
end
