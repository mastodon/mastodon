module Temple
  # Immutable map class which supports map merging
  # @api public
  class ImmutableMap
    include Enumerable

    def initialize(*map)
      @map = map.compact
    end

    def include?(key)
      @map.any? {|h| h.include?(key) }
    end

    def [](key)
      @map.each {|h| return h[key] if h.include?(key) }
      nil
    end

    def each
      keys.each {|k| yield(k, self[k]) }
    end

    def keys
      @map.inject([]) {|keys, h| keys.concat(h.keys) }.uniq
    end

    def values
      keys.map {|k| self[k] }
    end

    def to_hash
      result = {}
      each {|k, v| result[k] = v }
      result
    end
  end

  # Mutable map class which supports map merging
  # @api public
  class MutableMap < ImmutableMap
    def initialize(*map)
      super({}, *map)
    end

    def []=(key, value)
      @map.first[key] = value
    end

    def update(map)
      @map.first.update(map)
    end
  end

  class OptionMap < MutableMap
    def initialize(*map, &block)
      super(*map)
      @handler = block
      @valid = {}
      @deprecated = {}
    end

    def []=(key, value)
      validate_key!(key)
      super
    end

    def update(map)
      validate_map!(map)
      super
    end

    def valid_keys
      (keys + @valid.keys +
       @map.map {|h| h.valid_keys if h.respond_to?(:valid_keys) }.compact.flatten).uniq
    end

    def add_valid_keys(*keys)
      keys.flatten.each { |key| @valid[key] = true }
    end

    def add_deprecated_keys(*keys)
      keys.flatten.each { |key| @valid[key] = @deprecated[key] = true }
    end

    def validate_map!(map)
      map.to_hash.keys.each {|key| validate_key!(key) }
    end

    def validate_key!(key)
      @handler.call(self, key, :deprecated) if deprecated_key?(key)
      @handler.call(self, key, :invalid) unless valid_key?(key)
    end

    def deprecated_key?(key)
      @deprecated.include?(key) ||
        @map.any? {|h| h.deprecated_key?(key) if h.respond_to?(:deprecated_key?) }
    end

    def valid_key?(key)
      include?(key) || @valid.include?(key) ||
        @map.any? {|h| h.valid_key?(key) if h.respond_to?(:valid_key?) }
    end
  end
end
