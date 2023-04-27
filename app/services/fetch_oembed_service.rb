# frozen_string_literal: true

class FetchOEmbedService
  ENDPOINT_CACHE_EXPIRES_IN = 24.hours.freeze
  URL_REGEX                 = /(=(http[s]?(%3A|:)(\/\/|%2F%2F)))([^&]*)/i

  attr_reader :url, :options, :format, :endpoint_url

  def call(url, options = {})
    @url     = url
    @options = options

    if @options[:cached_endpoint]
      parse_cached_endpoint!
    else
      discover_endpoint!
    end

    fetch!
  end

  private

  def discover_endpoint!
    return if html.nil?

    @format = @options[:format]
    page    = Nokogiri::HTML(html)

    if @format.nil? || @format == :json
      @endpoint_url ||= page.at_xpath('//link[@type="application/json+oembed"]|//link[@type="text/json+oembed"]')&.attribute('href')&.value
      @format       ||= :json if @endpoint_url
    end

    if @format.nil? || @format == :xml
      @endpoint_url ||= page.at_xpath('//link[@type="text/xml+oembed"]')&.attribute('href')&.value
      @format       ||= :xml if @endpoint_url
    end

    return if @endpoint_url.blank?

    @endpoint_url = begin
      base_url = Addressable::URI.parse(@url)

      # If the OEmbed endpoint is given as http but the URL we opened
      # was served over https, we can assume OEmbed will be available
      # through https as well

      (base_url + @endpoint_url).tap do |absolute_url|
        absolute_url.scheme = base_url.scheme if base_url.scheme == 'https'
      end.to_s
    end

    cache_endpoint!
  rescue Addressable::URI::InvalidURIError
    @endpoint_url = nil
  end

  def parse_cached_endpoint!
    cached = @options[:cached_endpoint]

    return if cached[:endpoint].nil? || cached[:format].nil?

    @endpoint_url = Addressable::Template.new(cached[:endpoint]).expand(url: @url).to_s
    @format       = cached[:format]
  end

  def cache_endpoint!
    return unless URL_REGEX.match?(@endpoint_url)

    url_domain = Addressable::URI.parse(@url).normalized_host

    endpoint_hash = {
      endpoint: @endpoint_url.gsub(URL_REGEX, '={url}'),
      format: @format,
    }

    Rails.cache.write("oembed_endpoint:#{url_domain}", endpoint_hash, expires_in: ENDPOINT_CACHE_EXPIRES_IN)
  end

  def fetch!
    return if @endpoint_url.blank?

    body = Request.new(:get, @endpoint_url).perform do |res|
      res.code == 200 ? res.body_with_limit : nil
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
    oembed if oembed[:version].to_s == '1.0' && oembed[:type].present?
  end

  def html
    return @html if defined?(@html)

    @html = @options[:html] || Request.new(:get, @url).add_headers('Accept' => 'text/html').perform do |res|
      res.code != 200 || res.mime_type != 'text/html' ? nil : res.body_with_limit
    end
  end
end
