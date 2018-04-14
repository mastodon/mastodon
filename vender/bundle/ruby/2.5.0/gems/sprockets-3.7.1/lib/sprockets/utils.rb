require 'set'

module Sprockets
  # Internal: Utils, we didn't know where else to put it! Functions may
  # eventually be shuffled into more specific drawers.
  module Utils
    extend self

    # Internal: Check if object can safely be .dup'd.
    #
    # Similar to ActiveSupport #duplicable? check.
    #
    # obj - Any Object
    #
    # Returns false if .dup would raise a TypeError, otherwise true.
    def duplicable?(obj)
      if RUBY_VERSION >= "2.4.0"
        true
      else
        case obj
        when NilClass, FalseClass, TrueClass, Symbol, Numeric
          false
        else
          true
        end
      end
    end

    # Internal: Duplicate and store key/value on new frozen hash.
    #
    # Seperated for recursive calls, always use hash_reassoc(hash, *keys).
    #
    # hash - Hash
    # key  - Object key
    #
    # Returns Hash.
    def hash_reassoc1(hash, key)
      hash = hash.dup if hash.frozen?
      old_value = hash[key]
      old_value = old_value.dup if duplicable?(old_value)
      new_value = yield old_value
      new_value.freeze if duplicable?(new_value)
      hash.store(key, new_value)
      hash.freeze
    end

    # Internal: Duplicate and store key/value on new frozen hash.
    #
    # Similar to Hash#store for nested frozen hashes.
    #
    # hash  - Hash
    # key   - Object keys. Use multiple keys for nested hashes.
    # block - Receives current value at key.
    #
    # Examples
    #
    #     config = {paths: ["/bin", "/sbin"]}.freeze
    #     new_config = hash_reassoc(config, :paths) do |paths|
    #       paths << "/usr/local/bin"
    #     end
    #
    # Returns duplicated frozen Hash.
    def hash_reassoc(hash, *keys, &block)
      if keys.size == 1
        hash_reassoc1(hash, keys[0], &block)
      else
        hash_reassoc1(hash, keys[0]) do |value|
          hash_reassoc(value, *keys[1..-1], &block)
        end
      end
    end

    # Internal: Check if string has a trailing semicolon.
    #
    # str - String
    #
    # Returns true or false.
    def string_end_with_semicolon?(str)
      i = str.size - 1
      while i >= 0
        c = str[i].ord
        i -= 1

        # Need to compare against the ordinals because the string can be UTF_8 or UTF_32LE encoded
        # 0x0A == "\n"
        # 0x20 == " "
        # 0x09 == "\t"
        # 0x3B == ";"
        unless c == 0x0A || c == 0x20 || c == 0x09
          return c === 0x3B
        end
      end

      true
    end

    # Internal: Accumulate asset source to buffer and append a trailing
    # semicolon if necessary.
    #
    # buf    - String buffer to append to
    # source - String source to append
    #
    # Returns buf String.
    def concat_javascript_sources(buf, source)
      if source.bytesize > 0
        buf << source

        # If the source contains non-ASCII characters, indexing on it becomes O(N).
        # This will lead to O(N^2) performance in string_end_with_semicolon?, so we should use 32 bit encoding to make sure indexing stays O(1)
        source = source.encode(Encoding::UTF_32LE) unless source.ascii_only?

        if !string_end_with_semicolon?(source)
          buf << ";\n"
        elsif source[source.size - 1].ord != 0x0A
          buf << "\n"
        end
      end

      buf
    end

    # Internal: Prepends a leading "." to an extension if its missing.
    #
    #     normalize_extension("js")
    #     # => ".js"
    #
    #     normalize_extension(".css")
    #     # => ".css"
    #
    def normalize_extension(extension)
      extension = extension.to_s
      if extension[/^\./]
        extension
      else
        ".#{extension}"
      end
    end

    # Internal: Feature detect if UnboundMethods can #bind to any Object or
    # just Objects that share the same super class.
    # Basically if RUBY_VERSION >= 2.
    UNBOUND_METHODS_BIND_TO_ANY_OBJECT = begin
      foo = Module.new { def bar; end }
      foo.instance_method(:bar).bind(Object.new)
      true
    rescue TypeError
      false
    end

    # Internal: Inject into target module for the duration of the block.
    #
    # mod - Module
    #
    # Returns result of block.
    def module_include(base, mod)
      old_methods = {}

      mod.instance_methods.each do |sym|
        old_methods[sym] = base.instance_method(sym) if base.method_defined?(sym)
      end

      unless UNBOUND_METHODS_BIND_TO_ANY_OBJECT
        base.send(:include, mod) unless base < mod
      end

      mod.instance_methods.each do |sym|
        method = mod.instance_method(sym)
        base.send(:define_method, sym, method)
      end

      yield
    ensure
      mod.instance_methods.each do |sym|
        base.send(:undef_method, sym) if base.method_defined?(sym)
      end
      old_methods.each do |sym, method|
        base.send(:define_method, sym, method)
      end
    end

    # Internal: Post-order Depth-First search algorithm.
    #
    # Used for resolving asset dependencies.
    #
    # initial - Initial Array of nodes to traverse.
    # block   -
    #   node  - Current node to get children of
    #
    # Returns a Set of nodes.
    def dfs(initial)
      nodes, seen = Set.new, Set.new
      stack = Array(initial).reverse

      while node = stack.pop
        if seen.include?(node)
          nodes.add(node)
        else
          seen.add(node)
          stack.push(node)
          stack.concat(Array(yield node).reverse)
        end
      end

      nodes
    end

    # Internal: Post-order Depth-First search algorithm that gathers all paths
    # along the way.
    #
    # TODO: Rename function.
    #
    # path   - Initial Array node path
    # block  -
    #   node - Current node to get children of
    #
    # Returns an Array of node Arrays.
    def dfs_paths(path)
      paths = []
      stack, seen = [path], Set.new

      while path = stack.pop
        if !seen.include?(path.last)
          seen.add(path.last)
          paths << path if path.size > 1

          Array(yield path.last).reverse_each do |node|
            stack.push(path + [node])
          end
        end
      end

      paths
    end
  end
end
