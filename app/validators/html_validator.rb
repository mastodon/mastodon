# frozen_string_literal: true

class HtmlValidator < ActiveModel::EachValidator
  ERROR_RE = /Opening and ending tag mismatch|Unexpected end tag/

  def validate_each(record, attribute, value)
    return if value.blank?

    errors = html_errors(value)

    record.errors.add(attribute, I18n.t('html_validator.invalid_markup', error: errors.first.to_s)) unless errors.empty?
  end

  private

  def html_errors(str)
    fragment = Nokogiri::HTML.fragment(options[:wrap_with] ? "<#{options[:wrap_with]}>#{str}</#{options[:wrap_with]}>" : str)
    fragment.errors.select { |error| ERROR_RE =~ error.message }
  end
end
