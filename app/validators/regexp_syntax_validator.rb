# frozen_string_literal: true

class RegexpSyntaxValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    Regexp.compile(value)
  rescue RegexpError => e
    record.errors.add(attribute, I18n.t('applications.invalid_regexp', message: e.message))
  end
end
