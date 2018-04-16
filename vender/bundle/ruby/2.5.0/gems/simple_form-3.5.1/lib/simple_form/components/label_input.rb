# frozen_string_literal: true
module SimpleForm
  module Components
    module LabelInput
      extend ActiveSupport::Concern

      included do
        include SimpleForm::Components::Labels
      end

      def label_input(wrapper_options = nil)
        if options[:label] == false
          deprecated_component(:input, wrapper_options)
        else
          deprecated_component(:label, wrapper_options) + deprecated_component(:input, wrapper_options)
        end
      end

      private

      def deprecated_component(namespace, wrapper_options)
        method = method(namespace)

        if method.arity.zero?
          ActiveSupport::Deprecation.warn(SimpleForm::CUSTOM_INPUT_DEPRECATION_WARN % { name: namespace })

          method.call
        else
          method.call(wrapper_options)
        end
      end
    end
  end
end
