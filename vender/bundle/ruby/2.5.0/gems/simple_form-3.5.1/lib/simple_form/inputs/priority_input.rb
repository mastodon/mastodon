# frozen_string_literal: true
module SimpleForm
  module Inputs
    class PriorityInput < CollectionSelectInput
      def input(wrapper_options = nil)
        merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

        @builder.send(:"#{input_type}_select", attribute_name, input_priority,
                      input_options, merged_input_options)
      end

      def input_priority
        options[:priority] || SimpleForm.send(:"#{input_type}_priority")
      end

      protected

      def has_required?
        false
      end

      def skip_include_blank?
        super || input_priority.present?
      end
    end
  end
end
