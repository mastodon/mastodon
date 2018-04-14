
module Oj

  # A Hash subclass that normalizes the hash keys to allow lookup by the
  # key.to_s or key.to_sym. It also supports looking up hash values by methods
  # that match the keys.
  class EasyHash < Hash

    # Initializes the instance to an empty Hash.
    def initialize()
    end

    # Replaces the Object.respond_to?() method.
    # @param [Symbol] m method symbol
    # @return [Boolean] true for any method that matches an instance
    #                   variable reader, otherwise false.
    def respond_to?(m)
      return true if super
      return true if has_key?(key)
      return true if has_key?(key.to_s)
      has_key?(key.to_sym)
    end

    def [](key)
      return fetch(key, nil) if has_key?(key)
      return fetch(key.to_s, nil) if has_key?(key.to_s)
      fetch(key.to_sym, nil)
    end

    # Handles requests for Hash values. Others cause an Exception to be raised.
    # @param [Symbol|String] m method symbol
    # @return [Boolean] the value of the specified instance variable.
    # @raise [ArgumentError] if an argument is given. Zero arguments expected.
    # @raise [NoMethodError] if the instance variable is not defined.
    def method_missing(m, *args, &block)
      if m.to_s.end_with?('=')
        raise ArgumentError.new("wrong number of arguments (#{args.size} for 1 with #{m}) to method #{m}") if args.nil? or 1 != args.length
        m = m[0..-2]
        return store(m.to_s, args[0]) if has_key?(m.to_s)
        return store(m.to_sym, args[0]) if has_key?(m.to_sym)
        return store(m, args[0])
      else
        raise ArgumentError.new("wrong number of arguments (#{args.size} for 0 with #{m}) to method #{m}") unless args.nil? or args.empty?
        return fetch(m, nil) if has_key?(m)
        return fetch(m.to_s, nil) if has_key?(m.to_s)
        return fetch(m.to_sym, nil) if has_key?(m.to_sym)
      end
      raise NoMethodError.new("undefined method #{m}", m)
    end

  end # EasyHash
end # Oj
