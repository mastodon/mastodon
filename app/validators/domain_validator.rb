# frozen_string_literal: true

class DomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    domain = if options[:acct]
               value.split('@').last
             else
               value
             end

    record.errors.add(attribute, I18n.t('domain_validator.invalid_domain')) unless compliant?(domain)
  end

  private

  def compliant?(value)
    Addressable::URI.new.tap { |uri| uri.host = value }
  rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
    false
  end
end
