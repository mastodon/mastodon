# frozen_string_literal: true
module SimpleForm
  module Inputs
    class HiddenInput < Base
      disable :label, :errors, :hint, :required

      def input(wrapper_options = nil)
        merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

        @builder.hidden_field(attribute_name, merged_input_options)
      end

      private

      def required_class
        nil
      end
    end
  end
end
