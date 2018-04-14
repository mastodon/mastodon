# encoding: utf-8
# frozen_string_literal: true

module TTY
  class Prompt
    class Question
      # A class representing question validation.
      class Validation
       # Available validator names
        VALIDATORS = {
          email: /^[a-z0-9._%+-]+@([a-z0-9-]+\.)+[a-z]{2,6}$/i
        }.freeze

        attr_reader :pattern

        # Initialize a Validation
        #
        # @param [Object] pattern
        #
        # @return [undefined]
        #
        # @api private
        def initialize(pattern)
          @pattern = coerce(pattern)
        end

        # Convert validation into known type.
        #
        # @param [Object] pattern
        #
        # @raise [TTY::ValidationCoercion]
        #   raised when failed to convert validation
        #
        # @api private
        def coerce(pattern)
          case pattern
          when String, Symbol, Proc
            pattern
          when Regexp
            Regexp.new(pattern.to_s)
          else
            raise ValidationCoercion, "Wrong type, got #{pattern.class}"
          end
        end

        # Test if the input passes the validation
        #
        # @example
        #   Validation.new(/pattern/)
        #   validation.call(input) # => true
        #
        # @param [Object] input
        #  the input to validate
        #
        # @return [Boolean]
        #
        # @api public
        def call(input)
          if pattern.is_a?(String) || pattern.is_a?(Symbol)
            VALIDATORS.key?(pattern.to_sym)
            !VALIDATORS[pattern.to_sym].match(input).nil?
          elsif pattern.is_a?(Regexp)
            !pattern.match(input).nil?
          elsif pattern.is_a?(Proc)
            result = pattern.call(input)
            result.nil? ? false : result
          else false
          end
        end
      end # Validation
    end # Question
  end # Prompt
end # TTY
