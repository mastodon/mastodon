# frozen_string_literal: true

class FetchLinkCardService < BaseService
  URL_PATTERN = %r{
    (                                                                                                 #   $1 URL
      (https?:\/\/)                                                                                   #   $2 Protocol (required)
      (#{Twitter::Regex[:valid_domain]})                                                              #   $3 Domain(s)
      (?::(#{Twitter::Regex[:valid_port_number]}))?                                                   #   $4 Port number (optional)
      (/#{Twitter::Regex[:valid_url_path]}*)?                                                         #   $5 URL Path and anchor
      (\?#{Twitter::Regex[:valid_url_query_chars]}*#{Twitter::Regex[:valid_url_query_ending_chars]})? #   $6 Query String
    )
  }iox

  def call(status)
    @status = status
    @url    = parse_urls

    return if @url.nil? || @status.preview_cards.any?

    @url = @url.to_s

    RedisLock.acquire(lock_options) do |lock|
      if lock.acquired?
        @card = PreviewCard.find_by(url: @url)
        process_url if @card.nil? || @card.updated_at <= 2.weeks.ago
      else
        raise Mastodon::RaceConditionError
      end
    end

    attach_card if @card&.persisted?
  rescue HTTP::Error, Addressable::URI::InvalidURIError, Mastodon::LengthValidationError => e
    Rails.logger.debug "Error fetching link #{@url}: #{e}"
    nil
  end

  private

  def process_url
    @card ||= PreviewCard.new(url: @url)

    failed = Request.new(:head, @url).perform do |res|
      res.code != 405 && (res.code != 200 || res.mime_type != 'text/html')
    end

    return if failed

    Request.new(:get, @url).perform do |res|
      if res.code == 200 && res.mime_type == 'text/html'
        @html = res.body_with_limit
        @html_charset = res.charset
      else
        @html = nil
        @html_charset = nil
      end
    end

    return if @html.nil?

    attempt_oembed || attempt_opengraph
  end

  def attach_card
    @status.preview_cards << @card
  end

  def parse_urls
    if @status.local?
      urls = @status.text.scan(URL_PATTERN).map { |array| Addressable::URI.parse(array[0]).normalize }
    else
      html  = Nokogiri::HTML(@status.text)
      links = html.css('a')
      urls  = links.map { |a| Addressable::URI.parse(a['href']).normalize unless skip_link?(a) }.compact
    end

    urls.reject { |uri| bad_url?(uri) }.first
  end

  def bad_url?(uri)
    # Avoid local instance URLs and invalid URLs
    uri.host.blank? || TagManager.instance.local_url?(uri.to_s) || !%w(http https).include?(uri.scheme)
  end

  def skip_link?(a)
    # Avoid links for hashtags and mentions (microformats)
    a['rel']&.include?('tag') || a['class']&.include?('u-url')
  end

  def attempt_oembed
    embed = FetchOEmbedService.new.call(@url, html: @html)

    return false if embed.nil?

    @card.type          = embed[:type]
    @card.title         = embed[:title]         || ''
    @card.author_name   = embed[:author_name]   || ''
    @card.author_url    = embed[:author_url]    || ''
    @card.provider_name = embed[:provider_name] || ''
    @card.provider_url  = embed[:provider_url]  || ''
    @card.width         = 0
    @card.height        = 0

    case @card.type
    when 'link'
      @card.image_remote_url = embed[:thumbnail_url] if embed[:thumbnail_url].present?
    when 'photo'
      return false if embed[:url].blank?

      @card.embed_url        = embed[:url]
      @card.image_remote_url = embed[:url]
      @card.width            = embed[:width].presence  || 0
      @card.height           = embed[:height].presence || 0
    when 'video'
      @card.width            = embed[:width].presence  || 0
      @card.height           = embed[:height].presence || 0
      @card.html             = Formatter.instance.sanitize(embed[:html], Sanitize::Config::MASTODON_OEMBED)
      @card.image_remote_url = embed[:thumbnail_url] if embed[:thumbnail_url].present?
    when 'rich'
      # Most providers rely on <script> tags, which is a no-no
      return false
    end

    @card.save_with_optional_image!
  end

  def attempt_opengraph
    detector = CharlockHolmes::EncodingDetector.new
    detector.strip_tags = true

    guess = detector.detect(@html, @html_charset)
    page  = Nokogiri::HTML(@html, nil, guess&.fetch(:encoding, nil))

    if meta_property(page, 'twitter:player')
      @card.type   = :video
      @card.width  = meta_property(page, 'twitter:player:width') || 0
      @card.height = meta_property(page, 'twitter:player:height') || 0
      @card.html   = content_tag(:iframe, nil, src: meta_property(page, 'twitter:player'),
                                               width: @card.width,
                                               height: @card.height,
                                               allowtransparency: 'true',
                                               scrolling: 'no',
                                               frameborder: '0')
    else
      @card.type = :link
    end

    @card.title            = meta_property(page, 'og:title').presence || page.at_xpath('//title')&.content || ''
    @card.description      = meta_property(page, 'og:description').presence || meta_property(page, 'description') || ''
    @card.image_remote_url = meta_property(page, 'og:image') if meta_property(page, 'og:image')

    return if @card.title.blank? && @card.html.blank?

    @card.save_with_optional_image!
  end

  def meta_property(page, property)
    page.at_xpath("//meta[@property=\"#{property}\"]")&.attribute('content')&.value || page.at_xpath("//meta[@name=\"#{property}\"]")&.attribute('content')&.value
  end

  def lock_options
    { redis: Redis.current, key: "fetch:#{@url}" }
  end
end
