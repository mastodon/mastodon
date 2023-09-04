# frozen_string_literal: true

class URLValidator < ActiveModel::EachValidator
  VALID_SCHEMES = %w(http https).freeze

  def validate_each(record, attribute, value)
    @value = value

    record.errors.add(attribute, :invalid) unless compliant_url?
  end

  private

  def compliant_url?
    parsed_url.present? && valid_url_scheme? && valid_url_host?
  end

  def parsed_url
    Addressable::URI.parse(@value)
  rescue Addressable::URI::InvalidURIError
    false
  end

  def valid_url_scheme?
    VALID_SCHEMES.include?(parsed_url.scheme)
  end

  def valid_url_host?
    parsed_url.host.present?
  end
end
