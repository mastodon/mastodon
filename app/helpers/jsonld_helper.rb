# frozen_string_literal: true

module JsonLdHelper
  def equals_or_includes?(haystack, needle)
    haystack.is_a?(Array) ? haystack.include?(needle) : haystack == needle
  end

  def first_of_value(value)
    value.is_a?(Array) ? value.first : value
  end

  def value_or_id(value)
    value.is_a?(String) || value.nil? ? value : value['id']
  end

  def supported_context?(json)
    !json.nil? && equals_or_includes?(json['@context'], ActivityPub::TagManager::CONTEXT)
  end

  def canonicalize(json)
    graph = RDF::Graph.new << JSON::LD::API.toRdf(json)
    graph.dump(:normalize)
  end

  def fetch_resource(uri)
    response = build_request(uri).perform
    return if response.code != 200
    body_to_json(response.to_s)
  end

  def body_to_json(body)
    body.is_a?(String) ? Oj.load(body, mode: :strict) : body
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

  private

  def build_request(uri)
    request = Request.new(:get, uri)
    request.add_headers('Accept' => 'application/activity+json, application/ld+json')
    request
  end
end
