# frozen_string_literal: true

class LanguageValidator < ActiveModel::EachValidator
  include LanguagesHelper

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid) unless valid?(value)
  end

  private

  def valid?(str)
    if str.nil?
      true
    elsif str.is_a?(Array)
      str.all? { |x| valid_locale?(x) }
    else
      valid_locale?(str)
    end
  end
end
