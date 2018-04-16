require 'thread'

module ThreadSafe
  autoload :JRubyCacheBackend,           'thread_safe/jruby_cache_backend'
  autoload :MriCacheBackend,             'thread_safe/mri_cache_backend'
  autoload :NonConcurrentCacheBackend,   'thread_safe/non_concurrent_cache_backend'
  autoload :AtomicReferenceCacheBackend, 'thread_safe/atomic_reference_cache_backend'
  autoload :SynchronizedCacheBackend,    'thread_safe/synchronized_cache_backend'

  ConcurrentCacheBackend = if defined?(RUBY_ENGINE)
    case RUBY_ENGINE
    when 'jruby'; JRubyCacheBackend
    when 'ruby';  MriCacheBackend
    when 'rbx';   AtomicReferenceCacheBackend
    else
      warn 'ThreadSafe: unsupported Ruby engine, using a fully synchronized ThreadSafe::Cache implementation' if $VERBOSE
      SynchronizedCacheBackend
    end
  else
    MriCacheBackend
  end

  class Cache < ConcurrentCacheBackend
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

    def fetch_or_store(key, default_value = NULL)
      fetch(key) do
        put(key, block_given? ? yield(key) : (NULL == default_value ? raise_fetch_no_key : default_value))
      end
    end

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
    end unless method_defined?(:value?)

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
      if (initial_capacity = options[:initial_capacity]) && (!initial_capacity.kind_of?(0.class) || initial_capacity < 0)
        raise ArgumentError, ":initial_capacity must be a positive #{0.class}"
      end
      if (load_factor = options[:load_factor]) && (!load_factor.kind_of?(Numeric) || load_factor <= 0 || load_factor > 1)
        raise ArgumentError, ":load_factor must be a number between 0 and 1"
      end
    end
  end
end
