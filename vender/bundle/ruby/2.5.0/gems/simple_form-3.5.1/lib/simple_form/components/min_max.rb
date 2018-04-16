# frozen_string_literal: true
module SimpleForm
  module Components
    module MinMax
      def min_max(wrapper_options = nil)
        if numeric_validator = find_numericality_validator
          validator_options = numeric_validator.options
          input_html_options[:min] ||= minimum_value(validator_options)
          input_html_options[:max] ||= maximum_value(validator_options)
        end
        nil
      end

      private

      def integer?
        input_type == :integer
      end

      def minimum_value(validator_options)
        if integer? && validator_options.key?(:greater_than)
          evaluate_numericality_validator_option(validator_options[:greater_than]) + 1
        else
          evaluate_numericality_validator_option(validator_options[:greater_than_or_equal_to])
        end
      end

      def maximum_value(validator_options)
        if integer? && validator_options.key?(:less_than)
          evaluate_numericality_validator_option(validator_options[:less_than]) - 1
        else
          evaluate_numericality_validator_option(validator_options[:less_than_or_equal_to])
        end
      end

      def find_numericality_validator
        find_validator(:numericality)
      end

      def evaluate_numericality_validator_option(option)
        if option.is_a?(Numeric)
          option
        elsif option.is_a?(Symbol)
          object.send(option)
        elsif option.respond_to?(:call)
          option.call(object)
        end
      end
    end
  end
end
