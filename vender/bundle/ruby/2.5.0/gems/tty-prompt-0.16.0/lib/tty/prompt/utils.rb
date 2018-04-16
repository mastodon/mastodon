# encoding: utf-8
# frozen_string_literal: true

module TTY
  module Utils
    module_function

    BLANK_REGEX = /\A[[:space:]]*\z/o.freeze

    # Extract options hash from array argument
    #
    # @param [Array[Object]] args
    #
    # @api public
    def extract_options(args)
      options = args.last
      options.respond_to?(:to_hash) ? options.to_hash.dup : {}
    end

    def extract_options!(args)
      args.last.respond_to?(:to_hash) ? args.pop : {}
    end

    # Check if value is nil or an empty string
    #
    # @param [Object] value
    #   the value to check
    #
    # @return [Boolean]
    #
    # @api public
    def blank?(value)
      value.nil? ||
      value.respond_to?(:empty?) && value.empty? ||
      BLANK_REGEX === value
    end

    # Deep copy object
    #
    # @api public
    def deep_copy(object)
      Marshal.load(Marshal.dump(object))
    end
  end # Utils
end # TTY
