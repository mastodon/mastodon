# frozen_string_literal: true

module JsonLdHelper
  def bear_prefix(str)
    return str unless str&.start_with?('bear:')

    str.sub(/^bear:/, '')
  end

  def process_values(values)
    return unless values.is_a?(Array) && !values.first.is_a?(String)

    values.map do |value|
      process_value(value)
    end
  end

  def valid_uri?(uri)
    uri.blank? || !uri.start_with?('http://', 'https://')
  end

  def compare_unsupported_uri_scheme(comparison_url)
    return true if unsupported_uri_scheme?(comparison_url)

    # more code here ...
  end

  def process_object(object)
    return unless object.is_a?(Hash)

    return if non_matching_uri_hosts?(account.uri, object['id'])

    # more code here ...
  end

  def compact_values(value, compacted, key)
    next if value.nil? || !compacted.key?(key)

    # more code here ...
  end

  def compare_size(value, compacted_value)
    return nil if value.size != compacted_value.size

    # more code here ...
  end

  def compare_instance(value, compacted_value)
    return false unless value.instance_of?(compacted_value.class)

    # more code here ...
  end

  def process_json(json)
    return unless json.is_a?(Hash) && !unsupported_uri_scheme?(json['id'])

    # more code here ...
  end

  def handle_response_error(response)
    raise Mastodon::UnexpectedResponseError, response if !response_successful?(response) && (
      # ...condition...
    )

    # more code here ...
  end

  def valid_ld_json?(response)
    return false unless response.mime_type == 'application/ld+json'

    # more code here ...
  end

  def compare_json_id(json, compare_id)
    return if compare_id.present? && json['id'] != compare_id

    # more code here ...
  end

  def response_successful?(response)
    (200..299).cover?(response.code)
  end

  def is_unexpected_response?(response)
    response.code == 501 || ((400..499).cover?(response.code) && ![401, 408, 429].include?(response.code))
  end

  def load_document_failed(res)
    raise JSON::LD::JsonLdError::LoadingDocumentFailed unless res.code == 200 && res.mime_type == 'application/ld+json'

    # more code here ...
  end
end
