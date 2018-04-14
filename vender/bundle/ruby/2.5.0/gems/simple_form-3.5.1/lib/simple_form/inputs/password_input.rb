# frozen_string_literal: true
module SimpleForm
  module Inputs
    class PasswordInput < Base
      enable :placeholder, :maxlength, :minlength

      def input(wrapper_options = nil)
        merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

        @builder.password_field(attribute_name, merged_input_options)
      end
    end
  end
end
