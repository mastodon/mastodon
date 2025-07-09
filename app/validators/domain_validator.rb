# frozen_string_literal: true

class DomainValidator < ActiveModel::EachValidator
  MAX_DOMAIN_LENGTH = 256
  MIN_LABEL_LENGTH = 1
  MAX_LABEL_LENGTH = 63
  ALLOWED_CHARACTERS_RE = /^[a-z0-9-]+$/i

  def validate_each(record, attribute, value)
    return if value.blank?

    Array.wrap(value).each do |domain|
      if options[:acct]
        _, domain = domain.split('@')
        next if domain.blank?
      end

      record.errors.add(attribute, value.is_a?(Enumerable) ? :invalid_domain_on_line : :invalid, value: domain) unless compliant?(domain)
    end
  end

  private

  def compliant?(value)
    return false if value.blank?

    uri = Addressable::URI.new
    uri.host = value
    uri.normalized_host.size < MAX_DOMAIN_LENGTH && uri.normalized_host.split('.').all? { |label| label.size.between?(MIN_LABEL_LENGTH, MAX_LABEL_LENGTH) && label =~ ALLOWED_CHARACTERS_RE }
  rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
    false
  end
end
