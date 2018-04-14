# encoding: utf-8

require 'set'

class Sanitize
  module Config

    # Deeply freezes and returns the given configuration Hash.
    def self.freeze_config(config)
      if Hash === config
        config.each_value {|c| freeze_config(c) }
      elsif Array === config || Set === config
        config.each {|c| freeze_config(c) }
      end

      config.freeze
    end

    # Returns a new Hash containing the result of deeply merging *other_config*
    # into *config*. Does not modify *config* or *other_config*.
    #
    # This is the safest way to use a built-in Sanitize config as the basis for
    # your own custom config.
    def self.merge(config, other_config = {})
      raise ArgumentError, 'config must be a Hash' unless Hash === config
      raise ArgumentError, 'other_config must be a Hash' unless Hash === other_config

      merged = {}
      keys   = Set.new(config.keys + other_config.keys)

      keys.each do |key|
        oldval = config[key]

        if other_config.has_key?(key)
          newval = other_config[key]

          if Hash === oldval && Hash === newval
            merged[key] = oldval.empty? ? newval.dup : merge(oldval, newval)
          elsif Array === newval && key != :transformers
            merged[key] = Set.new(newval)
          else
            merged[key] = can_dupe?(newval) ? newval.dup : newval
          end
        else
          merged[key] = can_dupe?(oldval) ? oldval.dup : oldval
        end
      end

      merged
    end

    # Returns `true` if `dup` may be safely called on _value_, `false`
    # otherwise.
    def self.can_dupe?(value)
      !(true == value || false == value || value.nil? || Method === value || Numeric === value || Symbol === value)
    end
    private_class_method :can_dupe?

  end
end
