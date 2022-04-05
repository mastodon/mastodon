# frozen_string_literal: true

module JsonLdHelper
  def equals_or_includes?(haystack, needle)
    haystack.is_a?(Array) ? haystack.include?(needle) : haystack == needle
  end

  def equals_or_includes_any?(haystack, needles)
    needles.any? { |needle| equals_or_includes?(haystack, needle) }
  end

  def first_of_value(value)
    value.is_a?(Array) ? value.first : value
  end

  # The url attribute can be a string, an array of strings, or an array of objects.
  # The objects could include a mimeType. Not-included mimeType means it's text/html.
  def url_to_href(value, preferred_type = nil)
    single_value = begin
      if value.is_a?(Array) && !value.first.is_a?(String)
        value.find { |link| preferred_type.nil? || ((link['mimeType'].presence || 'text/html') == preferred_type) }
      elsif value.is_a?(Array)
        value.first
      else
        value
      end
    end

    if single_value.nil? || single_value.is_a?(String)
      single_value
    else
      single_value['href']
    end
  end

  def as_array(value)
    value.is_a?(Array) ? value : [value]
  end

  def value_or_id(value)
    value.is_a?(String) || value.nil? ? value : value['id']
  end

  def supported_context?(json)
    !json.nil? && equals_or_includes?(json['@context'], ActivityPub::TagManager::CONTEXT)
  end

  def unsupported_uri_scheme?(uri)
    !uri.start_with?('http://', 'https://')
  end

  def same_origin?(url_a, url_b)
    Addressable::URI.parse(url_a).host.casecmp(Addressable::URI.parse(url_b).host).zero?
  end

  def invalid_origin?(url)
    unsupported_uri_scheme?(url) || !same_origin?(url, @account.uri)
  end

  def canonicalize(json)
    graph = RDF::Graph.new << JSON::LD::API.toRdf(json, documentLoader: method(:load_jsonld_context))
    graph.dump(:normalize)
  end

  def fetch_resource(uri, id, on_behalf_of = nil)
    unless id
      json = fetch_resource_without_id_validation(uri, on_behalf_of)

      return if !json.is_a?(Hash) || unsupported_uri_scheme?(json['id'])

      uri = json['id']
    end

    json = fetch_resource_without_id_validation(uri, on_behalf_of)
    json.present? && json['id'] == uri ? json : nil
  end

  def fetch_resource_without_id_validation(uri, on_behalf_of = nil, raise_on_temporary_error = false)
    on_behalf_of ||= Account.representative

    build_request(uri, on_behalf_of).perform do |response|
      raise Mastodon::UnexpectedResponseError, response unless response_successful?(response) || response_error_unsalvageable?(response) || !raise_on_temporary_error

      body_to_json(response.body_with_limit) if response.code == 200
    end
  end

  def body_to_json(body, compare_id: nil)
    json = body.is_a?(String) ? Oj.load(body, mode: :strict) : body

    return if compare_id.present? && json['id'] != compare_id

    json
  rescue Oj::ParseError
    nil
  end

  def merge_context(context, new_context)
    if context.is_a?(Array)
      context << new_context
    else
      [context, new_context]
    end
  end

  def response_successful?(response)
    (200...300).cover?(response.code)
  end

  def response_error_unsalvageable?(response)
    response.code == 501 || ((400...500).cover?(response.code) && ![401, 408, 429].include?(response.code))
  end

  def build_request(uri, on_behalf_of = nil)
    Request.new(:get, uri).tap do |request|
      request.on_behalf_of(on_behalf_of) if on_behalf_of
      request.add_headers('Accept' => 'application/activity+json, application/ld+json')
    end
  end

  def load_jsonld_context(url, _options = {}, &_block)
    json = Rails.cache.fetch("jsonld:context:#{url}", expires_in: 30.days, raw: true) do
      request = Request.new(:get, url)
      request.add_headers('Accept' => 'application/ld+json')
      request.perform do |res|
        raise JSON::LD::JsonLdError::LoadingDocumentFailed unless res.code == 200 && res.mime_type == 'application/ld+json'

        res.body_with_limit
      end
    end

    doc = JSON::LD::API::RemoteDocument.new(json, documentUrl: url)

    block_given? ? yield(doc) : doc
  end
end
