# frozen_string_literal: true

module JsonLdHelper
  def equals_or_includes?(haystack, needle)
    haystack.is_a?(Array) ? haystack.include?(needle) : haystack == needle
  end

  def first_of_value(value)
    value.is_a?(Array) ? value.first : value
  end

  def supported_context?(json)
    equals_or_includes?(json['@context'], ActivityPub::TagManager::CONTEXT)
  end

  def fetch_resource(uri)
    response = build_request(uri).perform
    return if response.code != 200
    body_to_json(response.to_s)
  end

  def body_to_json(body)
    body.nil? ? nil : Oj.load(body, mode: :strict)
  rescue Oj::ParseError
    nil
  end

  private

  def build_request(uri)
    request = Request.new(:get, uri)
    request.add_headers('Accept' => 'application/activity+json, application/ld+json')
    request
  end
end
