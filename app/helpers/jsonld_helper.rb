# frozen_string_literal: true

module JsonLdHelper
  def equals_or_includes?(haystack, needle)
    haystack.is_a?(Array) ? haystack.include?(needle) : haystack == needle
  end

  def first_of_value(value)
    value.is_a?(Array) ? value.first : value
  end

  def find_href(url, rel = nil, type = nil)
    url = url.lazy.select do |element|
      case element
      when Hash
        [['rel', rel], ['mimeType', type]].all? do |pair|
          real = element[pair[0]]
          expected = pair[1]

          if expected.nil?
            true
          else
            case real
            when Array
              real.any? do |real_element|
                real_element.is_a?(String) && real_element.casecmp?(expected)
              end
            when String
              real.casecmp? expected
            when nil
              true
            else
              false
            end
          end
        end
      when String
        true
      else
        false
      end
    end

    first_href(url)
  end

  def first_href(object)
    case object
    when Hash, String
      url_element_to_href(object)
    when Enumerable
      hrefs = object.lazy.map { |url| url_element_to_href(url) }.reject(&:blank?)
      hrefs.first
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

  def canonicalize(json)
    graph = RDF::Graph.new << JSON::LD::API.toRdf(json)
    graph.dump(:normalize)
  end

  def fetch_resource(uri, id)
    unless id
      json = fetch_resource_without_id_validation(uri)
      return unless json
      uri = json['id']
    end

    json = fetch_resource_without_id_validation(uri)
    json.present? && json['id'] == uri ? json : nil
  end

  def fetch_resource_without_id_validation(uri)
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

  def url_element_to_href(url)
    case url
    when String
      url
    when Hash
      href = url['href']
      href.is_a?(String) ? href : nil
    end
  end
end
