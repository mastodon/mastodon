# frozen_string_literal: true

class FetchLinkCardService < BaseService
  URL_PATTERN = %r{https?://\S+}

  def call(status)
    # Get first http/https URL that isn't local
    url = parse_urls(status)

    return if url.nil?

    url  = url.to_s
    card = PreviewCard.where(status: status).first_or_initialize(status: status, url: url)
    res  = Request.new(:head, url).perform

    return if res.code != 200 || res.mime_type != 'text/html'

    attempt_opengraph(card, url) unless attempt_oembed(card, url)
  rescue HTTP::ConnectionError, OpenSSL::SSL::SSLError
    nil
  end

  private

  def parse_urls(status)
    if status.local?
      urls = status.text.match(URL_PATTERN).to_a.map { |uri| Addressable::URI.parse(uri).normalize }
    else
      html  = Nokogiri::HTML(status.text)
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

  def attempt_oembed(card, url)
    response = OEmbed::Providers.get(url)

    card.type          = response.type
    card.title         = response.respond_to?(:title)         ? response.title         : ''
    card.author_name   = response.respond_to?(:author_name)   ? response.author_name   : ''
    card.author_url    = response.respond_to?(:author_url)    ? response.author_url    : ''
    card.provider_name = response.respond_to?(:provider_name) ? response.provider_name : ''
    card.provider_url  = response.respond_to?(:provider_url)  ? response.provider_url  : ''
    card.width         = 0
    card.height        = 0

    case card.type
    when 'link'
      card.image = URI.parse(response.thumbnail_url) if response.respond_to?(:thumbnail_url)
    when 'photo'
      card.url    = response.url
      card.width  = response.width.presence  || 0
      card.height = response.height.presence || 0
    when 'video'
      card.width  = response.width.presence  || 0
      card.height = response.height.presence || 0
      card.html   = Formatter.instance.sanitize(response.html, Sanitize::Config::MASTODON_OEMBED)
    when 'rich'
      # Most providers rely on <script> tags, which is a no-no
      return false
    end

    card.save_with_optional_image!
  rescue OEmbed::NotFound
    false
  end

  def attempt_opengraph(card, url)
    response = Request.new(:get, url).perform

    return if response.code != 200 || response.mime_type != 'text/html'

    html = response.to_s

    detector = CharlockHolmes::EncodingDetector.new
    detector.strip_tags = true

    guess = detector.detect(html, response.charset)
    page = Nokogiri::HTML(html, nil, guess&.fetch(:encoding))

    card.type             = :link
    card.title            = meta_property(page, 'og:title') || page.at_xpath('//title')&.content
    card.description      = meta_property(page, 'og:description') || meta_property(page, 'description')
    card.image_remote_url = meta_property(page, 'og:image') if meta_property(page, 'og:image')

    return if card.title.blank?

    card.save_with_optional_image!
  end

  def meta_property(html, property)
    html.at_xpath("//meta[@property=\"#{property}\"]")&.attribute('content')&.value || html.at_xpath("//meta[@name=\"#{property}\"]")&.attribute('content')&.value
  end
end
