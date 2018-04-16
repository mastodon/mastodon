# frozen_string_literal: true
module SimpleForm
  module Inputs
    class CollectionRadioButtonsInput < CollectionInput
      def input(wrapper_options = nil)
        label_method, value_method = detect_collection_methods

        merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

        @builder.send(:"collection_#{input_type}",
          attribute_name, collection, value_method, label_method,
          input_options, merged_input_options,
          &collection_block_for_nested_boolean_style
        )
      end

      def input_options
        options = super
        apply_default_collection_options!(options)
        options
      end

      protected

      def apply_default_collection_options!(options)
        options[:item_wrapper_tag] ||= options.fetch(:item_wrapper_tag, SimpleForm.item_wrapper_tag)
        options[:item_wrapper_class] = [
          item_wrapper_class, options[:item_wrapper_class], SimpleForm.item_wrapper_class
        ].compact.presence if SimpleForm.include_default_input_wrapper_class

        options[:collection_wrapper_tag] ||= options.fetch(:collection_wrapper_tag, SimpleForm.collection_wrapper_tag)
        options[:collection_wrapper_class] = [
          options[:collection_wrapper_class], SimpleForm.collection_wrapper_class
        ].compact.presence
      end

      def collection_block_for_nested_boolean_style
        return unless nested_boolean_style?

        proc { |builder| build_nested_boolean_style_item_tag(builder) }
      end

      def build_nested_boolean_style_item_tag(collection_builder)
        collection_builder.radio_button + collection_builder.text.to_s
      end

      def item_wrapper_class
        "radio"
      end

      # Do not attempt to generate label[for] attributes by default, unless an
      # explicit html option is given. This avoids generating labels pointing to
      # non existent fields.
      def generate_label_for_attribute?
        false
      end
    end
  end
end
