module Hamster
  # @private
  class Trie
    def self.[](pairs)
      result = self.new(0)
      pairs.each { |key, val| result.put!(key, val) }
      result
    end

    # Returns the number of key-value pairs in the trie.
    attr_reader :size

    def initialize(significant_bits, size = 0, entries = [], children = [])
      @significant_bits = significant_bits
      @entries = entries
      @children = children
      @size = size
    end

    # Returns <tt>true</tt> if the trie contains no key-value pairs.
    def empty?
      size == 0
    end

    # Returns <tt>true</tt> if the given key is present in the trie.
    def key?(key)
      !!get(key)
    end

    # Calls <tt>block</tt> once for each entry in the trie, passing the key-value pair as parameters.
    def each(&block)
      # TODO: Using block.call here is slower than using yield by 5-10%, but
      # the latter segfaults on ruby 2.2 and above. Once that is fixed and
      # broken versions are sufficiently old, we should revert back to yield
      # with a warning that the broken versions are unsupported.
      #
      # For more context:
      # * https://bugs.ruby-lang.org/issues/11451
      # * https://github.com/hamstergem/hamster/issues/189
      @entries.each { |entry| block.call(entry) if entry }
      @children.each do |child|
        child.each(&block) if child
      end
      nil
    end

    def reverse_each(&block)
      @children.reverse_each do |child|
        child.reverse_each(&block) if child
      end
      @entries.reverse_each { |entry| yield(entry) if entry }
      nil
    end

    def reduce(memo)
      each { |entry| memo = yield(memo, entry) }
      memo
    end

    def select
      keys_to_delete = []
      each { |entry| keys_to_delete << entry[0] unless yield(entry) }
      bulk_delete(keys_to_delete)
    end

    # @return [Trie] A copy of `self` with the given value associated with the
    #   key (or `self` if no modification was needed because an identical
    #   key-value pair wes already stored
    def put(key, value)
      index = index_for(key)
      entry = @entries[index]

      if !entry
        entries = @entries.dup
        key = key.dup.freeze if key.is_a?(String) && !key.frozen?
        entries[index] = [key, value].freeze
        Trie.new(@significant_bits, @size + 1, entries, @children)
      elsif entry[0].eql?(key)
        if entry[1].equal?(value)
          self
        else
          entries = @entries.dup
          key = key.dup.freeze if key.is_a?(String) && !key.frozen?
          entries[index] = [key, value].freeze
          Trie.new(@significant_bits, @size, entries, @children)
        end
      else
        child = @children[index]
        if child
          new_child = child.put(key, value)
          if new_child.equal?(child)
            self
          else
            children = @children.dup
            children[index] = new_child
            new_self_size = @size + (new_child.size - child.size)
            Trie.new(@significant_bits, new_self_size, @entries, children)
          end
        else
          children = @children.dup
          children[index] = Trie.new(@significant_bits + 5).put!(key, value)
          Trie.new(@significant_bits, @size + 1, @entries, children)
        end
      end
    end

    # Put multiple elements into a Trie.  This is more efficient than several
    # calls to `#put`.
    #
    # @param key_value_pairs Enumerable of pairs (`[key, value]`)
    # @return [Trie] A copy of `self` after associated the given keys and
    #   values (or `self` if no modifications where needed).
    def bulk_put(key_value_pairs)
      new_entries = nil
      new_children = nil
      new_size = @size

      key_value_pairs.each do |key, value|
        index = index_for(key)
        entry = (new_entries || @entries)[index]

        if !entry
          new_entries ||= @entries.dup
          key = key.dup.freeze if key.is_a?(String) && !key.frozen?
          new_entries[index] = [key, value].freeze
          new_size += 1
        elsif entry[0].eql?(key)
          if !entry[1].equal?(value)
            new_entries ||= @entries.dup
            key = key.dup.freeze if key.is_a?(String) && !key.frozen?
            new_entries[index] = [key, value].freeze
          end
        else
          child = (new_children || @children)[index]
          if child
            new_child = child.put(key, value)
            if !new_child.equal?(child)
              new_children ||= @children.dup
              new_children[index] = new_child
              new_size += new_child.size - child.size
            end
          else
            new_children ||= @children.dup
            new_children[index] = Trie.new(@significant_bits + 5).put!(key, value)
            new_size += 1
          end
        end
      end

      if new_entries || new_children
        Trie.new(@significant_bits, new_size, new_entries || @entries, new_children || @children)
      else
        self
      end
    end

    # Returns <tt>self</tt> after overwriting the element associated with the specified key.
    def put!(key, value)
      index = index_for(key)
      entry = @entries[index]
      if !entry
        @size += 1
        key = key.dup.freeze if key.is_a?(String) && !key.frozen?
        @entries[index] = [key, value].freeze
      elsif entry[0].eql?(key)
        key = key.dup.freeze if key.is_a?(String) && !key.frozen?
        @entries[index] = [key, value].freeze
      else
        child = @children[index]
        if child
          old_child_size = child.size
          @children[index] = child.put!(key, value)
          @size += child.size - old_child_size
        else
          @children[index] = Trie.new(@significant_bits + 5).put!(key, value)
          @size += 1
        end
      end
      self
    end

    # Retrieves the entry corresponding to the given key. If not found, returns <tt>nil</tt>.
    def get(key)
      index = index_for(key)
      entry = @entries[index]
      if entry && entry[0].eql?(key)
        entry
      else
        child = @children[index]
        child.get(key) if child
      end
    end

    # Returns a copy of <tt>self</tt> with the given key (and associated value) deleted. If not found, returns <tt>self</tt>.
    def delete(key)
      find_and_delete(key) || Trie.new(@significant_bits)
    end

    # Delete multiple elements from a Trie.  This is more efficient than
    # several calls to `#delete`.
    #
    # @param keys [Enumerable] The keys to delete
    # @return [Trie]
    def bulk_delete(keys)
      new_entries = nil
      new_children = nil
      new_size = @size

      keys.each do |key|
        index = index_for(key)
        entry = (new_entries || @entries)[index]
        if !entry
          next
        elsif entry[0].eql?(key)
          new_entries ||= @entries.dup
          child = (new_children || @children)[index]
          if child
            # Bring up the first entry from the child into entries
            new_children ||= @children.dup
            new_children[index] = child.delete_at do |entry|
              new_entries[index] = entry
            end
          else
            new_entries[index] = nil
          end
          new_size -= 1
        else
          child = (new_children || @children)[index]
          if child
            copy = child.find_and_delete(key)
            unless copy.equal?(child)
              new_children ||= @children.dup
              new_children[index] = copy
              new_size -= (child.size - copy_size(copy))
            end
          end
        end
      end

      if new_entries || new_children
        Trie.new(@significant_bits, new_size, new_entries || @entries, new_children || @children)
      else
        self
      end
    end

    def include?(key, value)
      entry = get(key)
      entry && value.eql?(entry[1])
    end

    def at(index)
      @entries.each do |entry|
        if entry
          return entry if index == 0
          index -= 1
        end
      end
      @children.each do |child|
        if child
          if child.size >= index+1
            return child.at(index)
          else
            index -= child.size
          end
        end
      end
      nil
    end

    # Returns <tt>true</tt> if . <tt>eql?</tt> is synonymous with <tt>==</tt>
    def eql?(other)
      return true if equal?(other)
      return false unless instance_of?(other.class) && size == other.size
      each do |entry|
        return false unless other.include?(entry[0], entry[1])
      end
      true
    end
    alias :== :eql?

    protected

    # Returns a replacement instance after removing the specified key.
    # If not found, returns <tt>self</tt>.
    # If empty, returns <tt>nil</tt>.
    def find_and_delete(key)
      index = index_for(key)
      entry = @entries[index]
      if entry && entry[0].eql?(key)
        return delete_at(index)
      else
        child = @children[index]
        if child
          copy = child.find_and_delete(key)
          unless copy.equal?(child)
            children = @children.dup
            children[index] = copy
            new_size = @size - (child.size - copy_size(copy))
            return Trie.new(@significant_bits, new_size, @entries, children)
          end
        end
      end
      self
    end

    # Returns a replacement instance after removing the specified entry. If empty, returns <tt>nil</tt>
    def delete_at(index = @entries.index { |e| e })
      yield(@entries[index]) if block_given?
      if size > 1
        entries = @entries.dup
        child = @children[index]
        if child
          children = @children.dup
          children[index] = child.delete_at do |entry|
            entries[index] = entry
          end
        else
          entries[index] = nil
        end
        Trie.new(@significant_bits, @size - 1, entries, children || @children)
      end
    end

    private

    def index_for(key)
      (key.hash.abs >> @significant_bits) & 31
    end

    def copy_size(copy)
      copy ? copy.size : 0
    end
  end

  # @private
  EmptyTrie = Hamster::Trie.new(0)
end
