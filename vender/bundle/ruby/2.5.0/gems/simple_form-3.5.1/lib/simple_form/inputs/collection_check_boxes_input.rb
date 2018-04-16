# frozen_string_literal: true
module SimpleForm
  module Inputs
    class CollectionCheckBoxesInput < CollectionRadioButtonsInput
      protected

      # Checkbox components do not use the required html tag.
      # More info: https://github.com/plataformatec/simple_form/issues/340#issuecomment-2871956
      def has_required?
        false
      end

      def build_nested_boolean_style_item_tag(collection_builder)
        collection_builder.check_box + collection_builder.text.to_s
      end

      def item_wrapper_class
        "checkbox"
      end
    end
  end
end
