# frozen_string_literal: true
module SimpleForm
  module Components
    module HTML5
      def initialize(*)
        @html5 = false
      end

      def html5(wrapper_options = nil)
        @html5 = true

        input_html_options[:required]        = input_html_required_option
        input_html_options[:'aria-required'] = input_html_aria_required_option

        input_html_options[:'aria-invalid']  = has_errors? || nil

        nil
      end

      def html5?
        @html5
      end

      def input_html_required_option
        !options[:required].nil? ? required_field? : has_required?
      end

      def input_html_aria_required_option
        !options[:required].nil? ? (required_field? || nil) : (has_required? || nil)
      end

      def has_required?
        # We need to check browser_validations because
        # some browsers are still checking required even
        # if novalidate was given.
        required_field? && SimpleForm.browser_validations
      end
    end
  end
end
