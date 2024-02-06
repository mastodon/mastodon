# frozen_string_literal: true

class LinkDetailsExtractor
  include ActionView::Helpers::TagHelper
  include LanguagesHelper

  # Some publications wrap their JSON-LD data in their <script> tags
  # in commented-out CDATA blocks, they need to be removed before
  # attempting to parse JSON
  CDATA_JUNK_PATTERN = %r{^\s*(
    (/\*\s*<!\[CDATA\[\s*\*/) # Block comment style opening
    |
    (//\s*<!\[CDATA\[) # Single-line comment style opening
    |
    (/\*\s*\]\]>\s*\*/) # Block comment style closing
    |
    (//\s*\]\]>) # Single-line comment style closing
  )\s*$}x

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

    def type
      json['@type']
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

    def valid?
      json.present?
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
      image_description: image_alt || '',
      type: type,
      link_type: link_type,
      width: width || 0,
      height: height || 0,
      html: html || '',
      provider_name: provider_name || '',
      provider_url: provider_url || '',
      author_name: author_name || '',
      author_url: author_url || '',
      embed_url: embed_url || '',
      language: language,
      published_at: published_at.presence,
    }
  end

  def type
    player_url.present? ? :video : :link
  end

  def link_type
    if structured_data&.type == 'NewsArticle' || opengraph_tag('og:type') == 'article'
      :article
    else
      :unknown
    end
  end

  def html
    player_url.present? ? content_tag(:iframe, nil, src: player_url, width: width, height: height, allowfullscreen: 'true', allowtransparency: 'true', scrolling: 'no', frameborder: '0') : nil
  end

  def width
    opengraph_tag('twitter:player:width')
  end

  def height
    opengraph_tag('twitter:player:height')
  end

  def title
    html_entities.decode(structured_data&.headline || opengraph_tag('og:title') || document.xpath('//title').map(&:content).first)
  end

  def description
    html_entities.decode(structured_data&.description || opengraph_tag('og:description') || meta_tag('description'))
  end

  def published_at
    structured_data&.date_published || opengraph_tag('article:published_time')
  end

  def image
    valid_url_or_nil(opengraph_tag('og:image'))
  end

  def image_alt
    opengraph_tag('og:image:alt')
  end

  def canonical_url
    valid_url_or_nil(link_tag('canonical') || opengraph_tag('og:url'), same_origin_only: true) || @original_url.to_s
  end

  def provider_name
    html_entities.decode(structured_data&.publisher_name || opengraph_tag('og:site_name'))
  end

  def provider_url
    valid_url_or_nil(host_to_url(opengraph_tag('og:site')))
  end

  def author_name
    html_entities.decode(structured_data&.author_name || opengraph_tag('og:author') || opengraph_tag('og:author:username'))
  end

  def author_url
    structured_data&.author_url
  end

  def embed_url
    valid_url_or_nil(opengraph_tag('twitter:player:stream'))
  end

  def language
    valid_locale_or_nil(structured_data&.language || opengraph_tag('og:locale') || document.xpath('//html').pick('lang'))
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

    str.start_with?(%r{https?://}) ? str : "http://#{str}"
  end

  def valid_url_or_nil(str, same_origin_only: false)
    return if str.blank? || str == 'null'

    url = @original_url + Addressable::URI.parse(str)

    return if url.host.blank? || !%w(http https).include?(url.scheme) || (same_origin_only && url.host != @original_url.host)

    url.to_s
  rescue Addressable::URI::InvalidURIError
    nil
  end

  def link_tag(name)
    document.xpath("//link[@rel=\"#{name}\"]").pick('href')
  end

  def opengraph_tag(name)
    document.xpath("//meta[@property=\"#{name}\" or @name=\"#{name}\"]").pick('content')
  end

  def meta_tag(name)
    document.xpath("//meta[@name=\"#{name}\"]").pick('content')
  end

  def structured_data
    # Some publications have more than one JSON-LD definition on the page,
    # and some of those definitions aren't valid JSON either, so we have
    # to loop through here until we find something that is the right type
    # and doesn't break
    @structured_data ||= document.xpath('//script[@type="application/ld+json"]').filter_map do |element|
      json_ld = element.content&.gsub(CDATA_JUNK_PATTERN, '')

      next if json_ld.blank?

      structured_data = StructuredData.new(html_entities.decode(json_ld))

      next unless structured_data.valid?

      structured_data
    rescue Oj::ParseError, EncodingError
      Rails.logger.debug { "Invalid JSON-LD in #{@original_url}" }
      next
    end.first
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

  def html_entities
    @html_entities ||= HTMLEntities.new
  end
end
