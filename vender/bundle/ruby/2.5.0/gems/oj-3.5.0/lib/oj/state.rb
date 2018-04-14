
module JSON
  module Ext
    module Generator 
      unless defined?(::JSON::Ext::Generator::State)
        # This class exists for json gem compatibility only. While it can be
        # used as the options for other than compatibility a simple Hash is
        # recommended as it is simpler and performs better. The only bit
        # missing by not using a state object is the depth availability which
        # may be the depth during dumping or maybe not since it can be set and
        # the docs for depth= is the same as max_nesting. Note: Had to make
        # this a subclass of Object instead of Hash like EashyHash due to
        # conflicts with the json gem.
        class State

          def self.from_state(opts)
            s = self.new()
            s.clear()
            s.merge(opts)
            s
          end

          def initialize(opts = {})
            @attrs = {}

            # Populate with all vars then merge in opts. This class deviates from
            # the json gem in that any of the options can be set with the opts
            # argument. The json gem limits the opts use to 7 of the options.
            @attrs[:indent] = ''
            @attrs[:space] = ''
            @attrs[:space_before] = ''
            @attrs[:array_nl] = ''
            @attrs[:object_nl] = ''
            @attrs[:allow_nan] = false
            @attrs[:buffer_initial_length] = 1024 # completely ignored by Oj
            @attrs[:depth] = 0
            @attrs[:max_nesting] = 100
            @attrs[:check_circular?] = true
            @attrs[:ascii_only] = false

            @attrs.merge!(opts)
          end

          def to_h()
            return @attrs.dup
          end
          
          def to_hash()
            return @attrs.dup
          end
          
          def allow_nan?()
            @attrs[:allow_nan]
          end

          def ascii_only?()
            @attrs[:ascii_only]
          end

          def configure(opts)
            raise TypeError.new('expected a Hash') unless opts.respond_to?(:to_h)
            @attrs.merge!(opts.to_h)
          end

          def generate(obj)
            JSON.generate(obj)
          end

          def merge(opts)
            @attrs.merge!(opts)
          end

          # special rule for this.
          def buffer_initial_length=(len)
            len = 1024 if 0 >= len
            @attrs[:buffer_initial_length] = len
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
            key = key.to_sym
            @attrs.fetch(key, nil)
          end

          def []=(key, value)
            key = key.to_sym
            @attrs[key] = value
          end

          def clear()
            @attrs.clear()
          end

          def has_key?(k)
            @attrs.has_key?(key.to_sym)
          end
          
          # Handles requests for Hash values. Others cause an Exception to be raised.
          # @param [Symbol|String] m method symbol
          # @return [Boolean] the value of the specified instance variable.
          # @raise [ArgumentError] if an argument is given. Zero arguments expected.
          # @raise [NoMethodError] if the instance variable is not defined.
          def method_missing(m, *args, &block)
            if m.to_s.end_with?('=')
              raise ArgumentError.new("wrong number of arguments (#{args.size} for 1 with #{m}) to method #{m}") if args.nil? or 1 != args.length
              m = m.to_s[0..-2]
              m = m.to_sym
              return @attrs.store(m, args[0])
            else
              raise ArgumentError.new("wrong number of arguments (#{args.size} for 0 with #{m}) to method #{m}") unless args.nil? or args.empty?
              return @attrs[m.to_sym]
            end
            raise NoMethodError.new("undefined method #{m}", m)
          end

        end # State
      end # defined check
    end # Generator
  end # Ext

end # JSON
