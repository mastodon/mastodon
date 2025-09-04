# frozen_string_literal: true

class DateOfBirthInput < SimpleForm::Inputs::Base
  OPTIONS = [
    { autocomplete: 'bday-year', maxlength: 4, pattern: '[0-9]+', placeholder: 'YYYY' }.freeze,
    { autocomplete: 'bday-month', maxlength: 2, pattern: '[0-9]+', placeholder: 'MM' }.freeze,
    { autocomplete: 'bday-day', maxlength: 2, pattern: '[0-9]+', placeholder: 'DD' }.freeze,
  ].freeze

  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    merged_input_options[:inputmode] = 'numeric'

    values = (object.public_send(attribute_name) || '').to_s.split('-')

    safe_join(2.downto(0).map do |index|
      options = merged_input_options.merge(OPTIONS[index]).merge id: generate_id(index), 'aria-label': I18n.t("simple_form.labels.user.date_of_birth_#{index + 1}i"), value: values[index]
      @builder.text_field("#{attribute_name}(#{index + 1}i)", options)
    end)
  end

  def label_target
    "#{attribute_name}_3i"
  end

  private

  def generate_id(index)
    "#{object_name}_#{attribute_name}_#{index + 1}i"
  end
end
