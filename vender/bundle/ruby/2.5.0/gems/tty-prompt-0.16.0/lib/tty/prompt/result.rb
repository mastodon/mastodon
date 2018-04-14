# encoding: utf-8
# frozen_string_literal: true

module TTY
  class Prompt
    # Accumulates errors
    class Result
      attr_reader :question, :value, :errors

      def initialize(question, value, errors = [])
        @question = question
        @value  = value
        @errors = errors
      end

      def with(condition = nil, &block)
        validator = (condition || block)
        (new_value, validation_error) = validator.call(question, value)
        accumulated_errors = errors + Array(validation_error)

        if accumulated_errors.empty?
          Success.new(question, new_value)
        else
          Failure.new(question, new_value, accumulated_errors)
        end
      end

      def success?
        is_a?(Success)
      end

      def failure?
        is_a?(Failure)
      end

      class Success < Result
      end

      class Failure < Result
      end
    end
  end # Prompt
end # TTY
