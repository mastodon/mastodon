# frozen_string_literal: true

require 'addressable'
require 'nokogiri'

module Goldfinger
  class Client
    include Goldfinger::Utils

    def initialize(uri, opts = {})
      @uri = uri
      @ssl = opts.delete(:ssl) { true }
      @scheme = @ssl ? 'https' : 'http'
      @opts = opts
    end

    def finger
      response = perform_get(standard_url, @opts)

      return finger_from_template if response.code != 200

      Goldfinger::Result.new(response)
    rescue Addressable::URI::InvalidURIError
      raise Goldfinger::NotFoundError, 'Invalid URI'
    end

    private

    def finger_from_template
      template = perform_get(url, @opts)

      raise Goldfinger::NotFoundError, 'No host-meta on the server' if template.code != 200

      response = perform_get(url_from_template(template.body), @opts)

      raise Goldfinger::NotFoundError, 'No such user on the server' if response.code != 200

      Goldfinger::Result.new(response)
    end

    def url
      "#{@scheme}://#{domain}/.well-known/host-meta"
    end

    def standard_url
      "#{@scheme}://#{domain}/.well-known/webfinger?resource=#{@uri}"
    end

    def url_from_template(template)
      xml   = Nokogiri::XML(template)
      links = xml.xpath('//xmlns:Link[@rel="lrdd"]')

      raise Goldfinger::NotFoundError if links.empty?

      links.first.attribute('template').value.gsub('{uri}', @uri)
    rescue Nokogiri::XML::XPath::SyntaxError
      raise Goldfinger::Error, "Bad XML: #{template}"
    end

    def domain
      @uri.split('@').last
    end
  end
end
