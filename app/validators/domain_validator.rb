# frozen_string_literal: true

class DomainValidator < ActiveModel::EachValidator
  MAX_DOMAIN_LENGTH = 256
  MIN_LABEL_LENGTH = 1
  MAX_LABEL_LENGTH = 63
  ALLOWED_CHARACTERS_RE = /^[a-z0-9\-]+$/i

  def validate_each(record, attribute, value)
    return if value.blank?

    (options[:multiline] ? value.split : [value]).each do |domain|
      _, domain = domain.split('@') if options[:acct]

      next if domain.blank?

      record.errors.add(attribute, options[:multiline] ? :invalid_domain_on_line : :invalid, value: domain) unless compliant?(domain)
    end
  end

  private

  def compliant?(value)
    uri = Addressable::URI.new
    uri.host = value
    uri.normalized_host.size < MAX_DOMAIN_LENGTH && uri.normalized_host.split('.').all? { |label| label.size.between?(MIN_LABEL_LENGTH, MAX_LABEL_LENGTH) && label =~ ALLOWED_CHARACTERS_RE }
  rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
    false
  end
end
