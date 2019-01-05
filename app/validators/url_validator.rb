# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, I18n.t('applications.invalid_url')) unless compliant?(value)
  end

  private

  def compliant?(url)
    parsed_url = Addressable::URI.parse(url)
    parsed_url && %w(http https).include?(parsed_url.scheme) && parsed_url.host
  end
end
