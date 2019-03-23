# frozen_string_literal: true

class HtmlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    record.errors.add(attribute, I18n.t('html_validator.invalid_markup')) unless valid_html?(value)
  end

  private

  def valid_html?(str)
    fragment = Nokogiri::HTML.fragment(str)
    fragment.errors.empty?
  end
end
