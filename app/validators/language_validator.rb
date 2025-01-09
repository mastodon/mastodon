# frozen_string_literal: true

class LanguageValidator < ActiveModel::EachValidator
  include LanguagesHelper

  def validate_each(record, attribute, value)
    @value = value

    record.errors.add(attribute, :invalid) unless valid_locale_value?
  end

  private

  def valid_locale_value?
    if @value.nil?
      true
    elsif @value.is_a?(Array)
      @value.all? { |x| valid_locale?(x) }
    else
      valid_locale?(@value)
    end
  end
end
