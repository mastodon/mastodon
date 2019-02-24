# frozen_string_literal: true

class TrixEditorInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    safe_join [@builder.hidden_field(attribute_name, merged_input_options), template.content_tag(:'trix-editor', nil, input: [object_name, attribute_name].join('_'), class: 'rich-formatting')]
  end
end
