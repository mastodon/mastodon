# frozen_string_literal: true

class FetchOEmbedService
  attr_reader :url, :options, :format, :endpoint_url

  def call(url, options = {})
    @url     = url
    @options = options

    discover_endpoint!
    fetch!
  end

  private

  def discover_endpoint!
    return if html.nil?

    @format = @options[:format]
    page    = Nokogiri::HTML(html)

    if @format.nil? || @format == :json
      @endpoint_url ||= page.at_xpath('//link[@type="application/json+oembed"]')&.attribute('href')&.value
      @format       ||= :json if @endpoint_url
    end

    if @format.nil? || @format == :xml
      @endpoint_url ||= page.at_xpath('//link[@type="text/xml+oembed"]')&.attribute('href')&.value
      @format       ||= :xml if @endpoint_url
    end

    return if @endpoint_url.blank?

    @endpoint_url = (Addressable::URI.parse(@url) + @endpoint_url).to_s
  rescue Addressable::URI::InvalidURIError
    @endpoint_url = nil
  end

  def fetch!
    return if @endpoint_url.blank?

    body = Request.new(:get, @endpoint_url).perform do |res|
      res.code != 200 ? nil : res.body_with_limit
    end

    validate(parse_for_format(body)) if body.present?
  rescue Oj::ParseError, Ox::ParseError
    nil
  end

  def parse_for_format(body)
    case @format
    when :json
      Oj.load(body, mode: :strict)&.with_indifferent_access
    when :xml
      Ox.load(body, mode: :hash_no_attrs)&.with_indifferent_access&.dig(:oembed)
    end
  end

  def validate(oembed)
    oembed if oembed[:version] == '1.0' && oembed[:type].present?
  end

  def html
    return @html if defined?(@html)

    @html = @options[:html] || Request.new(:get, @url).perform do |res|
      res.code != 200 || res.mime_type != 'text/html' ? nil : res.body_with_limit
    end
  end
end
