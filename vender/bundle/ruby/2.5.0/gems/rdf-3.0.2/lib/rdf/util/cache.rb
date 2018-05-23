module RDF; module Util
  ##
  # A `Hash`-like cache that holds only weak references to the values it
  # caches, meaning that values contained in the cache can be garbage
  # collected. This allows the cache to dynamically adjust to changing
  # memory conditions, caching more objects when memory is plentiful, but
  # evicting most objects if memory pressure increases to the point of
  # scarcity.
  #
  # While this cache is something of an internal implementation detail of
  # RDF.rb, some external libraries do currently make use of it as well,
  # including [SPARQL](http://github.com/ruby-rdf/sparql/) and
  # [Spira](http://github.com/ruby-rdf/spira). Do be sure to include any changes
  # here in the RDF.rb changelog.
  #
  # @see   RDF::URI.intern
  # @see   http://en.wikipedia.org/wiki/Weak_reference
  # @since 0.2.0
  class Cache
    ##
    # @private
    def self.new(*args)
      # JRuby doesn't support `ObjectSpace#_id2ref` unless the `-X+O`
      # startup option is given.  In addition, ObjectSpaceCache is very slow
      # on Rubinius.  On those platforms we'll default to using
      # the WeakRef-based cache:
      if RUBY_PLATFORM == 'java' || (defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx')
        klass = WeakRefCache
      else
        klass = ObjectSpaceCache
      end
      cache = klass.allocate
      cache.send(:initialize, *args)
      cache
    end

    ##
    # @param  [Integer] capacity
    def initialize(capacity = -1)
      @capacity = capacity
      @cache  ||= {}
      @index  ||= {}
    end

    ##
    # @return [Integer]
    def size
      @cache.size
    end

    ##
    # @return [Boolean]
    def has_capacity?
      @capacity.equal?(-1) || @capacity > @cache.size
    end

    ##
    # This implementation relies on `ObjectSpace#_id2ref` and performs
    # optimally on Ruby >= 2.x; however, it does not work on JRuby
    # by default since much `ObjectSpace` functionality on that platform is
    # disabled unless the `-X+O` startup option is given.
    #
    # @see http://ruby-doc.org/core-2.2.2/ObjectSpace.html
    # @see http://ruby-doc.org/stdlib-2.2.0/libdoc/weakref/rdoc/WeakRef.html
    class ObjectSpaceCache < Cache
      ##
      # @param  [Object] key
      # @return [Object]
      def [](key)
        if value_id = @cache[key]
          ObjectSpace._id2ref(value_id) rescue nil
        end
      end

      ##
      # @param  [Object] key
      # @param  [Object] value
      # @return [Object]
      def []=(key, value)
        if has_capacity?
          id = value.__id__
          @cache[key] = id
          @index[id] = key
          ObjectSpace.define_finalizer(value, proc {|id| @cache.delete(@index.delete(id))})
        end
        value
      end

      ##
      # Remove cache entry for key
      #
      # @param [Object] key
      # @return [Object] the previously referenced object
      def delete(key)
        id = @cache[key]
        @cache.delete(key)
        @index.delete(id) if id
      end
    end # ObjectSpaceCache

    ##
    # This implementation uses the `WeakRef` class from Ruby's standard
    # library, and provides adequate performance on JRuby and on Ruby 2.x.
    #
    # @see http://ruby-doc.org/stdlib-2.2.0/libdoc/weakref/rdoc/WeakRef.html
    class WeakRefCache < Cache
      ##
      # @param  [Integer] capacity
      def initialize(capacity = -1)
        require 'weakref' unless defined?(::WeakRef)
        super
      end

      ##
      # @param  [Object] key
      # @return [Object]
      def [](key)
        if (ref = @cache[key])
          if ref.weakref_alive?
            value = ref.__getobj__ rescue nil
          else
            @cache.delete(key)
            nil
          end
        end
      end

      ##
      # @param  [Object] key
      # @param  [Object] value
      # @return [Object]
      def []=(key, value)
        if has_capacity?
          @cache[key] = WeakRef.new(value)
        end
        value
      end

      ##
      # Remove cache entry for key
      #
      # @param [Object] key
      # @return [Object] the previously referenced object
      def delete(key)
        ref = @cache.delete(key)
        ref.__getobj__ rescue nil
      end
    end # WeakRefCache
  end # Cache
end; end # RDF::Util
