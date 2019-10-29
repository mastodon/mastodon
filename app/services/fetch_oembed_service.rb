# frozen_string_literal: true

class FetchOEmbedService
  attr_reader :url, :options, :format, :endpoint_url

  def call(url, options = {})
    @url     = url
    @options = options

    if @options[:html].nil?
      parse_cache_endpoint!
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
      @endpoint_url ||= page.at_xpath('//link[@type="application/json+oembed"]')&.attribute('href')&.value
      @format       ||= :json if @endpoint_url
    end

    if @format.nil? || @format == :xml
      @endpoint_url ||= page.at_xpath('//link[@type="text/xml+oembed"]')&.attribute('href')&.value
      @format       ||= :xml if @endpoint_url
    end

    return if @endpoint_url.blank?

    @endpoint_url = (Addressable::URI.parse(@url) + @endpoint_url).to_s
    
    cache_endpoint
  rescue Addressable::URI::InvalidURIError
    @endpoint_url = nil
  end
  
  def parse_cache_endpoint!
    return if @options[:cached_endpoint].nil?

    cached=@options[:cached_endpoint]
	  return if cached["endpoint"].nil? || cached["format"].nil?
    
	  url_encoded=URI.encode_www_form_component(@url)
	  if cached["append"].nil?
	    @endpoint_url = cached["endpoint"]+url_encoded
	  else
	    @endpoint_url = cached["endpoint"]+url_encoded+"%26format%3D"+cached["append"]
	  end
    @format = cached["format"]
  end
  
  def cache_endpoint
    url_domain=Addressable::URI.parse(@url).host
    endpoint=@endpoint_url.match(/^.*(?=(http[s]?(%3A|:)(\/\/|%2F%2F)))/).to_s
    unless endpoint.nil?
	    if @endpoint_url.match(/format(=|%3D)json$/)
		    endpoint_hash={"endpoint" => endpoint,"format" => @format,"append" => "json"}
      elsif @endpoint_url.match(/format(=|%3D)xml$/)
      	endpoint_hash={"endpoint" => endpoint,"format" => @format,"append" => "xml"}
      else
        endpoint_hash={"endpoint" => endpoint,"format" => @format}
      end
      Rails.cache.write("oembed_endpoint_#{url_domain}", endpoint_hash, :expires_in => 24.hours)
    end
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
