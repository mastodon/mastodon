# frozen_string_literal: true

class LinkDetailsExtractor
  include ActionView::Helpers::TagHelper

  class StructuredData
    SUPPORTED_TYPES = %w(
      NewsArticle
      WebPage
    ).freeze

    def initialize(data)
      @data = data
    end

    def headline
      json['headline']
    end

    def description
      json['description']
    end

    def language
      json['inLanguage']
    end

    def image
      obj = first_of_value(json['image'])

      return obj['url'] if obj.is_a?(Hash)

      obj
    end

    def date_published
      json['datePublished']
    end

    def date_modified
      json['dateModified']
    end

    def author_name
      author['name']
    end

    def author_url
      author['url']
    end

    def publisher_name
      publisher['name']
    end

    def publisher_logo
      publisher.dig('logo', 'url')
    end

    private

    def author
      first_of_value(json['author']) || {}
    end

    def publisher
      first_of_value(json['publisher']) || {}
    end

    def first_of_value(arr)
      arr.is_a?(Array) ? arr.first : arr
    end

    def root_array(root)
      root.is_a?(Array) ? root : [root]
    end

    def json
      @json ||= root_array(Oj.load(@data)).find { |obj| SUPPORTED_TYPES.include?(obj['@type']) } || {}
    end
  end

  def initialize(original_url, html, html_charset)
    @original_url = Addressable::URI.parse(original_url)
    @html         = html
    @html_charset = html_charset
  end

  def to_preview_card_attributes
    {
      title: title || '',
      description: description || '',
      image_remote_url: image,
      type: type,
      width: width || 0,
      height: height || 0,
      html: html || '',
      provider_name: provider_name || '',
      provider_url: provider_url || '',
      author_name: author_name || '',
      author_url: author_url || '',
      embed_url: embed_url || '',
      language: language,
    }
  end

  def type
    player_url.present? ? :video : :link
  end

  def html
    player_url.present? ? content_tag(:iframe, nil, src: player_url, width: width, height: height, allowtransparency: 'true', scrolling: 'no', frameborder: '0') : nil
  end

  def width
    opengraph_tag('twitter:player:width')
  end

  def height
    opengraph_tag('twitter:player:height')
  end

  def title
    structured_data&.headline || opengraph_tag('og:title') || document.xpath('//title').map(&:content).first
  end

  def description
    structured_data&.description || opengraph_tag('og:description') || meta_tag('description')
  end

  def image
    valid_url_or_nil(opengraph_tag('og:image'))
  end

  def canonical_url
    valid_url_or_nil(opengraph_tag('og:url') || link_tag('canonical'), same_origin_only: true) || @original_url.to_s
  end

  def provider_name
    structured_data&.publisher_name || opengraph_tag('og:site_name')
  end

  def provider_url
    valid_url_or_nil(host_to_url(opengraph_tag('og:site')))
  end

  def author_name
    structured_data&.author_name || opengraph_tag('og:author') || opengraph_tag('og:author:username')
  end

  def author_url
    structured_data&.author_url
  end

  def embed_url
    valid_url_or_nil(opengraph_tag('twitter:player:stream'))
  end

  def language
    valid_locale_or_nil(structured_data&.language || opengraph_tag('og:locale') || document.xpath('//html').map { |element| element['lang'] }.first)
  end

  def icon
    valid_url_or_nil(structured_data&.publisher_icon || link_tag('apple-touch-icon') || link_tag('shortcut icon'))
  end

  private

  def player_url
    valid_url_or_nil(opengraph_tag('twitter:player'))
  end

  def host_to_url(str)
    return if str.blank?

    str.start_with?(/https?:\/\//) ? str : "http://#{str}"
  end

  def valid_url_or_nil(str, same_origin_only: false)
    return if str.blank?

    url = @original_url + Addressable::URI.parse(str)

    return if url.host.blank? || !%w(http https).include?(url.scheme) || (same_origin_only && url.host != @original_url.host)

    url.to_s
  rescue Addressable::URI::InvalidURIError
    nil
  end

  def valid_locale_or_nil(str)
    return nil if str.blank?

    code,  = str.split(/_-/) # Strip out the region from e.g. en_US or ja-JA
    locale = ISO_639.find(code)
    locale&.alpha2
  end

  def link_tag(name)
    document.xpath("//link[@rel=\"#{name}\"]").map { |link| link['href'] }.first
  end

  def opengraph_tag(name)
    document.xpath("//meta[@property=\"#{name}\" or @name=\"#{name}\"]").map { |meta| meta['content'] }.first
  end

  def meta_tag(name)
    document.xpath("//meta[@name=\"#{name}\"]").map { |meta| meta['content'] }.first
  end

  def structured_data
    @structured_data ||= begin
      json_ld = document.xpath('//script[@type="application/ld+json"]').map(&:content).first
      json_ld.present? ? StructuredData.new(json_ld) : nil
    rescue Oj::ParseError
      nil
    end
  end

  def document
    @document ||= Nokogiri::HTML(@html, nil, encoding)
  end

  def encoding
    @encoding ||= begin
      guess = detector.detect(@html, @html_charset)
      guess&.fetch(:confidence, 0).to_i > 60 ? guess&.fetch(:encoding, nil) : nil
    end
  end

  def detector
    @detector ||= CharlockHolmes::EncodingDetector.new.tap do |detector|
      detector.strip_tags = true
    end
  end
end
