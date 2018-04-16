# frozen_string_literal: true
module SimpleForm
  module Inputs
    class NumericInput < Base
      enable :placeholder, :min_max

      def input(wrapper_options = nil)
        input_html_classes.unshift("numeric")
        if html5?
          input_html_options[:type] ||= "number"
          input_html_options[:step] ||= integer? ? 1 : "any"
        end

        merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

        @builder.text_field(attribute_name, merged_input_options)
      end
    end
  end
end
