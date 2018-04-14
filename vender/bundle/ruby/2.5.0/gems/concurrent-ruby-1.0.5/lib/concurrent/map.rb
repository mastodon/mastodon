require 'thread'
require 'concurrent/constants'
require 'concurrent/synchronization'

module Concurrent
  # @!visibility private
  module Collection

    # @!visibility private
    MapImplementation = if Concurrent.java_extensions_loaded?
                          # noinspection RubyResolve
                          JRubyMapBackend
                        elsif defined?(RUBY_ENGINE)
                          case RUBY_ENGINE
                          when 'ruby'
                            require 'concurrent/collection/map/mri_map_backend'
                            MriMapBackend
                          when 'rbx'
                            require 'concurrent/collection/map/atomic_reference_map_backend'
                            AtomicReferenceMapBackend
                          when 'jruby+truffle'
                            require 'concurrent/collection/map/atomic_reference_map_backend'
                            AtomicReferenceMapBackend
                          else
                            warn 'Concurrent::Map: unsupported Ruby engine, using a fully synchronized Concurrent::Map implementation' if $VERBOSE
                            require 'concurrent/collection/map/synchronized_map_backend'
                            SynchronizedMapBackend
                          end
                        else
                          MriMapBackend
                        end
  end

  # `Concurrent::Map` is a hash-like object and should have much better performance
  # characteristics, especially under high concurrency, than `Concurrent::Hash`.
  # However, `Concurrent::Map `is not strictly semantically equivalent to a ruby `Hash`
  # -- for instance, it does not necessarily retain ordering by insertion time as `Hash`
  # does. For most uses it should do fine though, and we recommend you consider
  # `Concurrent::Map` instead of `Concurrent::Hash` for your concurrency-safe hash needs.
  #
  # > require 'concurrent'
  # >
  # > map = Concurrent::Map.new
  class Map < Collection::MapImplementation

    # @!macro [new] map_method_is_atomic
    #   This method is atomic. Atomic methods of `Map` which accept a block
    #   do not allow the `self` instance to be used within the block. Doing
    #   so will cause a deadlock.

    # @!method put_if_absent
    #   @!macro map_method_is_atomic

    # @!method compute_if_absent
    #   @!macro map_method_is_atomic

    # @!method compute_if_present
    #   @!macro map_method_is_atomic

    # @!method compute
    #   @!macro map_method_is_atomic

    # @!method merge_pair
    #   @!macro map_method_is_atomic

    # @!method replace_pair
    #   @!macro map_method_is_atomic

    # @!method replace_if_exists
    #   @!macro map_method_is_atomic

    # @!method get_and_set
    #   @!macro map_method_is_atomic

    # @!method delete
    #   @!macro map_method_is_atomic

    # @!method delete_pair
    #   @!macro map_method_is_atomic

    def initialize(options = nil, &block)
      if options.kind_of?(::Hash)
        validate_options_hash!(options)
      else
        options = nil
      end

      super(options)
      @default_proc = block
    end

    def [](key)
      if value = super # non-falsy value is an existing mapping, return it right away
        value
        # re-check is done with get_or_default(key, NULL) instead of a simple !key?(key) in order to avoid a race condition, whereby by the time the current thread gets to the key?(key) call
        # a key => value mapping might have already been created by a different thread (key?(key) would then return true, this elsif branch wouldn't be taken and an incorrent +nil+ value
        # would be returned)
        # note: nil == value check is not technically necessary
      elsif @default_proc && nil == value && NULL == (value = get_or_default(key, NULL))
        @default_proc.call(self, key)
      else
        value
      end
    end

    alias_method :get, :[]
    alias_method :put, :[]=

    # @!macro [attach] map_method_not_atomic
    #   The "fetch-then-act" methods of `Map` are not atomic. `Map` is intended
    #   to be use as a concurrency primitive with strong happens-before
    #   guarantees. It is not intended to be used as a high-level abstraction
    #   supporting complex operations. All read and write operations are
    #   thread safe, but no guarantees are made regarding race conditions
    #   between the fetch operation and yielding to the block. Additionally,
    #   this method does not support recursion. This is due to internal
    #   constraints that are very unlikely to change in the near future.
    def fetch(key, default_value = NULL)
      if NULL != (value = get_or_default(key, NULL))
        value
      elsif block_given?
        yield key
      elsif NULL != default_value
        default_value
      else
        raise_fetch_no_key
      end
    end

    # @!macro map_method_not_atomic
    def fetch_or_store(key, default_value = NULL)
      fetch(key) do
        put(key, block_given? ? yield(key) : (NULL == default_value ? raise_fetch_no_key : default_value))
      end
    end

    # @!macro map_method_is_atomic
    def put_if_absent(key, value)
      computed = false
      result = compute_if_absent(key) do
        computed = true
        value
      end
      computed ? nil : result
    end unless method_defined?(:put_if_absent)

    def value?(value)
      each_value do |v|
        return true if value.equal?(v)
      end
      false
    end

    def keys
      arr = []
      each_pair {|k, v| arr << k}
      arr
    end unless method_defined?(:keys)

    def values
      arr = []
      each_pair {|k, v| arr << v}
      arr
    end unless method_defined?(:values)

    def each_key
      each_pair {|k, v| yield k}
    end unless method_defined?(:each_key)

    def each_value
      each_pair {|k, v| yield v}
    end unless method_defined?(:each_value)

    alias_method :each, :each_pair unless method_defined?(:each)

    def key(value)
      each_pair {|k, v| return k if v == value}
      nil
    end unless method_defined?(:key)
    alias_method :index, :key if RUBY_VERSION < '1.9'

    def empty?
      each_pair {|k, v| return false}
      true
    end unless method_defined?(:empty?)

    def size
      count = 0
      each_pair {|k, v| count += 1}
      count
    end unless method_defined?(:size)

    def marshal_dump
      raise TypeError, "can't dump hash with default proc" if @default_proc
      h = {}
      each_pair {|k, v| h[k] = v}
      h
    end

    def marshal_load(hash)
      initialize
      populate_from(hash)
    end

    undef :freeze

    # @!visibility private
    DEFAULT_OBJ_ID_STR_WIDTH = 0.size == 4 ? 7 : 14 # we want to look "native", 7 for 32-bit, 14 for 64-bit
    # override default #inspect() method: firstly, we don't want to be spilling our guts (i-vars), secondly, MRI backend's
    # #inspect() call on its @backend i-var will bump @backend's iter level while possibly yielding GVL
    def inspect
      id_str = (object_id << 1).to_s(16).rjust(DEFAULT_OBJ_ID_STR_WIDTH, '0')
      "#<#{self.class.name}:0x#{id_str} entries=#{size} default_proc=#{@default_proc.inspect}>"
    end

    private
    def raise_fetch_no_key
      raise KeyError, 'key not found'
    end

    def initialize_copy(other)
      super
      populate_from(other)
    end

    def populate_from(hash)
      hash.each_pair {|k, v| self[k] = v}
      self
    end

    def validate_options_hash!(options)
      if (initial_capacity = options[:initial_capacity]) && (!initial_capacity.kind_of?(Integer) || initial_capacity < 0)
        raise ArgumentError, ":initial_capacity must be a positive Integer"
      end
      if (load_factor = options[:load_factor]) && (!load_factor.kind_of?(Numeric) || load_factor <= 0 || load_factor > 1)
        raise ArgumentError, ":load_factor must be a number between 0 and 1"
      end
    end
  end
end
