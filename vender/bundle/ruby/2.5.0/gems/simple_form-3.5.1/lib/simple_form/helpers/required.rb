# frozen_string_literal: true
module SimpleForm
  module Helpers
    module Required
      private

      def required_field?
        @required
      end

      def calculate_required
        if !options[:required].nil?
          options[:required]
        elsif has_validators?
          required_by_validators?
        else
          required_by_default?
        end
      end

      def required_by_validators?
        (attribute_validators + reflection_validators).any? { |v| v.kind == :presence && valid_validator?(v) }
      end

      def required_by_default?
        SimpleForm.required_by_default
      end

      # Do not use has_required? because we want to add the class
      # regardless of the required option.
      def required_class
        required_field? ? :required : :optional
      end
    end
  end
end
