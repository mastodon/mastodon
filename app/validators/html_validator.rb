# frozen_string_literal: true

class HtmlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    errors = html_errors(value)
    unless errors.empty?
      record.errors.add(attribute, I18n.t('html_validator.invalid_markup', error: errors.first.to_s))
    end
  end

  private

  def html_errors(str)
    fragment = Nokogiri::HTML.fragment(str)
    fragment.errors
  end
end
