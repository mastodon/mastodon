module Hamster
  # Including `Associable` in your container class gives it an `update_in`
  # method.
  #
  # To mix in `Associable`, your class must implement two methods:
  #
  # * `fetch(index, default = (missing_default = true))`
  # * `put(index, item = yield(get(index)))`
  # * `get(key)`
  #
  # See {Vector#fetch}, {Vector#put}, {Hash#fetch}, and {Hash#put} for examples.
  module Associable
    # Return a new container with a deeply nested value modified to the result
    # of the given code block.  When traversing the nested containers
    # non-existing keys are created with empty `Hash` values.
    #
    # The code block receives the existing value of the deeply nested key/index
    # (or `nil` if it doesn't exist). This is useful for "transforming" the
    # value associated with a certain key/index.
    #
    # Naturally, the original container and sub-containers are left unmodified;
    # new data structure copies are created along the path as needed.
    #
    # @example
    #   v = Hamster::Vector[123, 456, 789, Hamster::Hash["a" => Hamster::Vector[5, 6, 7]]]
    #   v.update_in(3, "a", 1) { |value| value + 9 }
    #   # => Hamster::Vector[123, 456, 789, Hamster::Hash["a" => Hamster::Vector[5, 15, 7]]]
    #   hash = Hamster::Hash["a" => Hamster::Hash["b" => Hamster::Hash["c" => 42]]]
    #   hash.update_in("a", "b", "c") { |value| value + 5 }
    #   # => Hamster::Hash["a" => Hamster::Hash["b" => Hamster::Hash["c" => 47]]]
    #
    # @param key_path [Object(s)] List of keys/indexes which form the path to the key to be modified
    # @yield [value] The previously stored value
    # @yieldreturn [Object] The new value to store
    # @return [Associable]
    def update_in(*key_path, &block)
      if key_path.empty?
        raise ArgumentError, "must have at least one key in path"
      end
      key = key_path[0]
      if key_path.size == 1
        new_value = block.call(fetch(key, nil))
      else
        value = fetch(key, EmptyHash)
        new_value = value.update_in(*key_path[1..-1], &block)
      end
      put(key, new_value)
    end

    # Return the value of successively indexing into a collection.
    # If any of the keys is not present in the collection, return `nil`.
    # keys that the Hamster type doesn't understand, raises an argument error
    #
    # @example
    #   h = Hamster::Hash[:a => 9, :b => Hamster::Vector['a', 'b'], :e => nil]
    #   h.dig(:b, 0)    # => "a"
    #   h.dig(:b, 5)    # => nil
    #   h.dig(:b, 0, 0) # => nil
    #   h.dig(:b, :a)   # ArgumentError
    # @params keys to fetch from the collection
    # @return [Object]
    def dig(key, *rest)
      value = get(key)
      if rest.empty? || value.nil?
        value
      elsif value.respond_to?(:dig)
        value.dig(*rest)
      end
    end
  end
end
