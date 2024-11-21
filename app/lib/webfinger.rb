# frozen_string_literal: true

class Webfinger
  class Error < StandardError; end
  class GoneError < Error; end
  class RedirectError < Error; end

  class Response
    ACTIVITYPUB_READY_TYPE = ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].freeze

    attr_reader :uri

    def initialize(uri, body)
      @uri  = uri
      @json = Oj.load(body, mode: :strict)

      validate_response!
    end

    def subject
      @json['subject']
    end

    def link(rel, attribute)
      links.dig(rel, 0, attribute)
    end

    def self_link_href
      self_link.fetch('href')
    end

    private

    def links
      @links ||= @json.fetch('links', []).group_by { |link| link['rel'] }
    end

    def self_link
      links.fetch('self', []).find do |link|
        ACTIVITYPUB_READY_TYPE.include?(link['type'])
      end
    end

    def validate_response!
      raise Webfinger::Error, "Missing subject in response for #{@uri}" if subject.blank?
      raise Webfinger::Error, "Missing self link in response for #{@uri}" if self_link.blank?
    end
  end

  def initialize(uri)
    _, @domain = uri.split('@')

    raise ArgumentError, 'Webfinger requested for local account' if @domain.nil?

    @uri = uri
  end

  def perform
    Response.new(@uri, body_from_webfinger)
  rescue Oj::ParseError
    raise Webfinger::Error, "Invalid JSON in response for #{@uri}"
  rescue Addressable::URI::InvalidURIError
    raise Webfinger::Error, "Invalid URI for #{@uri}"
  end

  private

  def body_from_webfinger(url = standard_url, use_fallback = true)
    webfinger_request(url).perform do |res|
      if res.code == 200
        body = res.body_with_limit
        raise Webfinger::Error, "Request for #{@uri} returned empty response" if body.empty?

        body
      elsif res.code == 404 && use_fallback
        body_from_host_meta
      elsif res.code == 410
        raise Webfinger::GoneError, "#{@uri} is gone from the server"
      else
        raise Webfinger::Error, "Request for #{@uri} returned HTTP #{res.code}"
      end
    end
  end

  def body_from_host_meta
    host_meta_request.perform do |res|
      if res.code == 200
        body_from_webfinger(url_from_template(res.body_with_limit), false)
      else
        raise Webfinger::Error, "Request for #{@uri} returned HTTP #{res.code}"
      end
    end
  end

  def url_from_template(str)
    link = Nokogiri::XML(str).at_xpath('//xmlns:Link[@rel="lrdd"]')

    if link.present?
      link['template'].gsub('{uri}', @uri)
    else
      raise Webfinger::Error, "Request for #{@uri} returned host-meta without link to Webfinger"
    end
  rescue Nokogiri::XML::XPath::SyntaxError
    raise Webfinger::Error, "Invalid XML encountered in host-meta for #{@uri}"
  end

  def host_meta_request
    Request.new(:get, host_meta_url).add_headers('Accept' => 'application/xrd+xml, application/xml, text/xml')
  end

  def webfinger_request(url)
    Request.new(:get, url).add_headers('Accept' => 'application/jrd+json, application/json')
  end

  def standard_url
    if @domain.end_with? '.onion'
      "http://#{@domain}/.well-known/webfinger?resource=#{@uri}"
    else
      "https://#{@domain}/.well-known/webfinger?resource=#{@uri}"
    end
  end

  def host_meta_url
    if @domain.end_with? '.onion'
      "http://#{@domain}/.well-known/host-meta"
    else
      "https://#{@domain}/.well-known/host-meta"
    end
  end
end
