# frozen_string_literal: true

class DomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, I18n.t('domain_validator.invalid_domain')) unless compliant?(value)
  end

  private

  def compliant?(value)
    Addressable::URI.new.tap { |uri| uri.host = value }
  rescue Addressable::URI::InvalidURIError
    false
  end
end
