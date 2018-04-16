# frozen_string_literal: true

require 'oj'

module Goldfinger
  # @!attribute [r] subject
  #   @return [String] URI that identifies the entity that the JRD describes.
  # @!attribute [r] aliases
  #   @return [Array] Zero or more URI strings that identify the same entity as the "subject" URI.
  class Result
    MIME_TYPES = [
      'application/jrd+json',
      'application/json',
      'application/xrd+xml',
      'application/xml',
      'text/xml',
    ].freeze

    attr_reader :subject, :aliases

    def initialize(response)
      @mime_type  = response.mime_type
      @body       = response.body
      @subject    = nil
      @aliases    = []
      @links      = {}
      @properties = {}

      parse
    end

    # The "properties" object comprises zero or more name/value pairs whose
    # names are URIs (referred to as "property identifiers") and whose
    # values are strings or nil.
    # @see #property
    # @return [Array] Array form of the hash
    def properties
      @properties.to_a
    end

    # Returns a property for a key
    # @param key [String]
    # @return [String]
    def property(key)
      @properties[key]
    end

    # The "links" array has any number of member objects, each of which
    # represents a link.
    # @see #link
    # @return [Array] Array form of the hash
    def links
      @links.to_a
    end

    # Returns a key for a relation
    # @param key [String]
    # @return [Goldfinger::Link]
    def link(rel)
      @links[rel]
    end

    private

    def parse
      case @mime_type
      when 'application/jrd+json', 'application/json'
        parse_json
      when 'application/xrd+xml', 'application/xml', 'text/xml'
        parse_xml
      else
        raise Goldfinger::Error, "Invalid response mime type: #{@mime_type}"
      end
    end

    def parse_json
      json = Oj.load(@body.to_s, mode: :null)

      @subject    = json['subject']
      @aliases    = json['aliases'] || []
      @properties = json['properties'] || {}

      json['links'].each do |link|
        tmp = Hash[link.keys.map { |key| [key.to_sym, link[key]] }]
        @links[link['rel']] = Goldfinger::Link.new(tmp)
      end
    end

    def parse_xml
      xml = Nokogiri::XML(@body)

      @subject = xml.at_xpath('//xmlns:Subject').content
      @aliases = xml.xpath('//xmlns:Alias').map(&:content)

      properties = xml.xpath('/xmlns:XRD/xmlns:Property')
      properties.each { |prop| @properties[prop.attribute('type').value] = prop.attribute('nil') ? nil : prop.content }

      xml.xpath('//xmlns:Link').each do |link|
        rel = link.attribute('rel').value
        tmp = Hash[link.attributes.keys.map { |key| [key.to_sym, link.attribute(key).value] }]

        tmp[:titles] = {}
        tmp[:properties] = {}

        link.xpath('.//xmlns:Title').each { |title| tmp[:titles][title.attribute('lang').value] = title.content }
        link.xpath('.//xmlns:Property').each { |prop| tmp[:properties][prop.attribute('type').value] = prop.attribute('nil') ? nil : prop.content }

        @links[rel] = Goldfinger::Link.new(tmp)
      end
    end
  end
end
