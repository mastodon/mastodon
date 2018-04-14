# frozen_string_literal: true
module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups.
    module Readonly
      def readonly(wrapper_options = nil)
        if readonly_attribute? && !has_readonly?
          input_html_options[:readonly] ||= true
          input_html_classes << :readonly
        end
        nil
      end

      private

      def readonly_attribute?
        object.class.respond_to?(:readonly_attributes) &&
          object.persisted? &&
          object.class.readonly_attributes.include?(attribute_name.to_s)
      end
    end
  end
end
