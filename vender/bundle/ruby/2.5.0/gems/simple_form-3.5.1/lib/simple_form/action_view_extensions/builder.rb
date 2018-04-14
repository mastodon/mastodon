# frozen_string_literal: true
module SimpleForm
  module ActionViewExtensions
    # A collection of methods required by simple_form but added to rails default form.
    # This means that you can use such methods outside simple_form context.
    module Builder

      # Wrapper for using SimpleForm inside a default rails form.
      # Example:
      #
      #   form_for @user do |f|
      #     f.simple_fields_for :posts do |posts_form|
      #       # Here you have all simple_form methods available
      #       posts_form.input :title
      #     end
      #   end
      def simple_fields_for(*args, &block)
        options = args.extract_options!
        options[:wrapper] = self.options[:wrapper] if options[:wrapper].nil?
        options[:defaults] ||= self.options[:defaults]
        options[:wrapper_mappings] ||= self.options[:wrapper_mappings]

        if self.class < ActionView::Helpers::FormBuilder
          options[:builder] ||= self.class
        else
          options[:builder] ||= SimpleForm::FormBuilder
        end
        fields_for(*args, options, &block)
      end
    end
  end
end

module ActionView::Helpers
  class FormBuilder
    include SimpleForm::ActionViewExtensions::Builder
  end
end
