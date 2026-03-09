# frozen_string_literal: true

module RecommendedComponent
  def recommended(_wrapper_options = nil)
    return unless options[:recommended]

    key = options[:recommended].is_a?(Symbol) ? options[:recommended] : :recommended
    options[:label_text] = ->(raw_label_text, _required_label_text, _label_present) { safe_join([raw_label_text, ' ', content_tag(:span, I18n.t(key, scope: 'simple_form'), class: key)]) }

    nil
  end
end

SimpleForm.include_component(RecommendedComponent)
