# frozen_string_literal: true

module JsonLdHelper
  include ContextHelper

  def equals_or_includes?(haystack, needle)
    Array(haystack).include?(needle)
  end

  def equals_or_includes_any?(haystack, needles)
    Array(needles).any? { |needle| equals_or_includes?(haystack, needle) }
  end

  def first_of_value(value)
    value.is_a?(Array) ? value.first : value
  end

  def uri_from_bearcap(str)
    return str unless str&.start_with?('bear:')
    Addressable::URI.parse(str).query_values['u']
  end

  # Handles url being a String, Array of Strings, or Array of Hashes (possibly with mimeType)
  def url_to_href(value, preferred_type = nil)
    values = value.is_a?(Hash) ? [value] : value
    if values.is_a?(Array) && !values.first.is_a?(String)
      link = values.find do |link|
        preferred_type.nil? || (link['mimeType'].presence || 'text/html') == preferred_type
      end
      link.nil? || link.is_a?(String) ? link : link['href']
    elsif values.is_a?(Array)
      values.first
    else
      values
    end
  end

  def url_to_media_type(value, preferred_type = nil)
    values = value.is_a?(Hash) ? [value] : value
    return unless values.is_a?(Array) && !values.first.is_a?(String)
    link = values.find do |l|
      preferred_type.nil? || (l['mimeType'].presence || 'text/html') == preferred_type
    end
    link&.dig('mediaType')
  end

  def as_array(value)
    Array(value).compact
  end

  def value_or_id(value)
    value.is_a?(String) || value.nil? ? value : value['id']
  end

  def supported_context?(json)
    json.present? && equals_or_includes?(json['@context'], ActivityPub::TagManager::CONTEXT)
  end

  def unsupported_uri_scheme?(uri)
    uri.blank? || !(uri.start_with?('http://') || uri.start_with?('https://'))
  end

  def non_matching_uri_hosts?(base_url, comparison_url)
    return true if unsupported_uri_scheme?(comparison_url)
    base_host = Addressable::URI.parse(base_url).host
    comp_host = Addressable::URI.parse(comparison_url).host
    !base_host.casecmp(comp_host).zero?
  end

  def safe_prefetched_embed(account, object, context)
    return unless object.is_a?(Hash)
    object = object.merge('@context' => context)
    return if value_or_id(first_of_value(object['attributedTo'])) != account.uri
    return if non_matching_uri_hosts?(account.uri, object['id'])
    object
  end

  def canonicalize(json)
    graph = RDF::Graph.new << JSON::LD::API.toRdf(json, documentLoader: method(:load_jsonld_context))
    graph.dump(:normalize)
  end

  def compact(json)
    compacted = JSON::LD::API.compact(json.without('signature'), full_context, documentLoader: method(:load_jsonld_context))
    compacted['signature'] = json['signature']
    compacted
  end

  # Patch compacted JSON-LD for compatibility (see docstring for details)
  def patch_for_forwarding!(original, compacted)
    original.without('@context', 'signature').each do |key, value|
      next if value.nil? || !compacted.key?(key)
      compacted_value = compacted[key]
      if value.is_a?(Hash) && compacted_value.is_a?(Hash)
        patch_for_forwarding!(value, compacted_value)
      elsif value.is_a?(Array)
        compacted_value = [compacted_value] unless compacted_value.is_a?(Array)
        return nil if value.size != compacted_value.size
        compacted[key] = value.zip(compacted_value).map do |v, vc|
          if v.is_a?(Hash) && vc.is_a?(Hash)
            patch_for_forwarding!(v, vc)
            vc
          elsif v == 'https://www.w3.org/ns/activitystreams#Public' && vc == 'as:Public'
            v
          else
            vc
          end
        end
      elsif value == 'https://www.w3.org/ns/activitystreams#Public' && compacted_value == 'as:Public'
        compacted[key] = value
      end
    end
  end

  # Check if compaction is safe (see docstring for details)
  def safe_for_forwarding?(original, compacted)
    original.without('@context', 'signature').all? do |key, value|
      compacted_value = compacted[key]
      return false unless value.instance_of?(compacted_value.class)
      if value.is_a?(Hash)
        safe_for_forwarding?(value, compacted_value)
      elsif value.is_a?(Array)
        value.zip(compacted_value).all? do |v, vc|
          v.is_a?(Hash) ? (vc.is_a?(Hash) && safe_for_forwarding?(v, vc)) : v == vc
        end
      else
        value == compacted_value
      end
    end
  end

  def fetch_resource(uri, id_is_known, on_behalf_of = nil, raise_on_error: :none, request_options: {})
    unless id_is_known
      json = fetch_resource_without_id_validation(uri, on_behalf_of, raise_on_error: raise_on_error)
      return unless json.is_a?(Hash) && !unsupported_uri_scheme?(json['id'])
      uri = json['id']
    end
    json = fetch_resource_without_id_validation(uri, on_behalf_of, raise_on_error: raise_on_error, request_options: request_options)
    json.present? && json['id'] == uri ? json : nil
  end

  def fetch_resource_without_id_validation(uri, on_behalf_of = nil, raise_on_error: :none, request_options: {})
    on_behalf_of ||= Account.representative
    build_request(uri, on_behalf_of, options: request_options).perform do |response|
      raise Mastodon::UnexpectedResponseError, response if !response_successful?(response) && (
        raise_on_error == :all ||
        (!response_error_unsalvageable?(response) && raise_on_error == :temporary)
      )
      body_to_json(response.body_with_limit) if response.code == 200 && valid_activitypub_content_type?(response)
    end
  end

  def valid_activitypub_content_type?(response)
    return true if response.mime_type == 'application/activity+json'
    return false unless response.mime_type == 'application/ld+json'
    response.headers[HTTP::Headers::CONTENT_TYPE]&.split(';')&.map(&:strip)&.any? do |str|
      str.start_with?('profile="') && str[9...-1].split.include?('https://www.w3.org/ns/activitystreams')
    end
  end

  def body_to_json(body, compare_id: nil)
    json = body.is_a?(String) ? Oj.load(body, mode: :strict) : body
    return if compare_id.present? && json['id'] != compare_id
    json
  rescue Oj::ParseError
    nil
  end

  def response_successful?(response)
    (200..299).include?(response.code)
  end

  def response_error_unsalvageable?(response)
    response.code == 501 || ((400..499).include?(response.code) && ![401, 408, 429].include?(response.code))
  end

  def build_request(uri, on_behalf_of = nil, options: {})
    Request.new(:get, uri, **options).tap do |request|
      request.on_behalf_of(on_behalf_of) if on_behalf_of
      request.add_headers('Accept' => 'application/activity+json, application/ld+json')
    end
  end

  def load_jsonld_context(url, _options = {}, &block)
    json = Rails.cache.fetch("jsonld:context:#{url}", expires_in: 30.days, raw: true) do
      request = Request.new(:get, url)
      request.add_headers('Accept' => 'application/ld+json')
      request.perform do |res|
        raise JSON::LD::JsonLdError::LoadingDocumentFailed unless res.code == 200 && res.mime_type == 'application/ld+json'
        res.body_with_limit
      end
    end
    doc = JSON::LD::API::RemoteDocument.new(json, documentUrl: url)
    block ? yield(doc) : doc
  end
end
