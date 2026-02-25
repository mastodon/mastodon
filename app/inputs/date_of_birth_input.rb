# frozen_string_literal: true

class DateOfBirthInput < SimpleForm::Inputs::Base
  OPTIONS = {
    day: { autocomplete: 'bday-day', maxlength: 2, pattern: '[0-9]+', placeholder: 'DD' },
    month: { autocomplete: 'bday-month', maxlength: 2, pattern: '[0-9]+', placeholder: 'MM' },
    year: { autocomplete: 'bday-year', maxlength: 4, pattern: '[0-9]+', placeholder: 'YYYY' },
  }.freeze

  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    merged_input_options[:inputmode] = 'numeric'

    safe_join(
      ordered_options.map do |option|
        options = merged_input_options
          .merge(OPTIONS[option])
          .merge(
            id: generate_id(option),
            'aria-label': I18n.t("simple_form.labels.user.date_of_birth_#{param_for(option)}"),
            value: values[option]
          )
        @builder.text_field("#{attribute_name}(#{param_for(option)})", options)
      end
    )
  end

  def label_target
    "#{attribute_name}_#{param_for(ordered_options.first)}"
  end

  private

  def ordered_options
    I18n.t('date.order').map(&:to_sym)
  end

  def generate_id(option)
    "#{object_name}_#{attribute_name}_#{param_for(option)}"
  end

  def param_for(option)
    "#{ActionView::Helpers::DateTimeSelector::POSITION[option]}i"
  end

  def values
    Date._parse((object.public_send(attribute_name) || '').to_s).transform_keys(mon: :month, mday: :day)
  end
end
