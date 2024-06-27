# frozen_string_literal: true

class FetchLinkCardService < BaseService
  include Redisable
  include Lockable

  URL_PATTERN = %r{
    (#{Twitter::TwitterText::Regex[:valid_url_preceding_chars]})                                                                #   $1 preceding chars
    (                                                                                                                           #   $2 URL
      (https?://)                                                                                                               #   $3 Protocol (required)
      (#{Twitter::TwitterText::Regex[:valid_domain]})                                                                           #   $4 Domain(s)
      (?::(#{Twitter::TwitterText::Regex[:valid_port_number]}))?                                                                #   $5 Port number (optional)
      (/#{Twitter::TwitterText::Regex[:valid_url_path]}*)?                                                                      #   $6 URL Path and anchor
      (\?#{Twitter::TwitterText::Regex[:valid_url_query_chars]}*#{Twitter::TwitterText::Regex[:valid_url_query_ending_chars]})? #   $7 Query String
    )
  }iox

  # URL size limit to safely store in PosgreSQL's unique indexes
  BYTESIZE_LIMIT = 2692

  def call(status)
    @status       = status
    @original_url = parse_urls

    return if @original_url.nil? || @status.with_preview_card?

    @url = @original_url.to_s

    with_redis_lock("fetch:#{@original_url}") do
      @card = PreviewCard.find_by(url: @url)
      process_url if @card.nil? || @card.updated_at <= 2.weeks.ago || @card.missing_image?
    end

    attach_card if @card&.persisted?
  rescue HTTP::Error, OpenSSL::SSL::SSLError, Addressable::URI::InvalidURIError, Mastodon::HostValidationError, Mastodon::LengthValidationError, Encoding::UndefinedConversionError => e
    Rails.logger.debug { "Error fetching link #{@original_url}: #{e}" }
    nil
  end

  private

  def process_url
    @card ||= PreviewCard.new(url: @url)

    attempt_oembed || attempt_opengraph
  end

  def html
    return @html if defined?(@html)

    @html = Request.new(:get, @url).add_headers('Accept' => 'text/html', 'User-Agent' => "#{Mastodon::Version.user_agent} Bot").perform do |res|
      next unless res.code == 200 && res.mime_type == 'text/html'

      # We follow redirects, and ideally we want to save the preview card for
      # the destination URL and not any link shortener in-between, so here
      # we set the URL to the one of the last response in the redirect chain
      @url  = res.request.uri.to_s
      @card = PreviewCard.find_or_initialize_by(url: @url) if @card.url != @url

      @html_charset = res.charset

      res.truncated_body
    end
  end

  def attach_card
    with_redis_lock("attach_card:#{@status.id}") do
      return if @status.with_preview_card?

      PreviewCardsStatus.create(status: @status, preview_card: @card, url: @original_url)
      Rails.cache.delete(@status)
      Trends.links.register(@status)
    end
  end

  def parse_urls
    urls = if @status.local?
             @status.text.scan(URL_PATTERN).map { |array| Addressable::URI.parse(array[1]).normalize }
           else
             document = Nokogiri::HTML(@status.text)
             links = document.css('a')

             links.filter_map { |a| Addressable::URI.parse(a['href']) unless skip_link?(a) }.filter_map(&:normalize)
           end

    urls.reject { |uri| bad_url?(uri) }.first
  end

  def bad_url?(uri)
    # Avoid local instance URLs and invalid URLs
    uri.host.blank? || TagManager.instance.local_url?(uri.to_s) || !%w(http https).include?(uri.scheme) || uri.to_s.bytesize > BYTESIZE_LIMIT
  end

  def mention_link?(anchor)
    @status.mentions.any? do |mention|
      anchor['href'] == ActivityPub::TagManager.instance.url_for(mention.account)
    end
  end

  def skip_link?(anchor)
    # Avoid links for hashtags and mentions (microformats)
    anchor['rel']&.include?('tag') || anchor['class']&.match?(/u-url|h-card/) || mention_link?(anchor)
  end

  def attempt_oembed
    service         = FetchOEmbedService.new
    url_domain      = Addressable::URI.parse(@url).normalized_host
    cached_endpoint = Rails.cache.read("oembed_endpoint:#{url_domain}")

    embed   = service.call(@url, cached_endpoint: cached_endpoint) unless cached_endpoint.nil?
    embed ||= service.call(@url, html: html) unless html.nil?

    return false if embed.nil?

    url = Addressable::URI.parse(service.endpoint_url)

    @card.type          = embed[:type]
    @card.title         = embed[:title]         || ''
    @card.author_name   = embed[:author_name]   || ''
    @card.author_url    = embed[:author_url].present? ? (url + embed[:author_url]).to_s : ''
    @card.provider_name = embed[:provider_name] || ''
    @card.provider_url  = embed[:provider_url].present? ? (url + embed[:provider_url]).to_s : ''
    @card.width         = 0
    @card.height        = 0

    case @card.type
    when 'link'
      @card.image_remote_url = (url + embed[:thumbnail_url]).to_s if embed[:thumbnail_url].present?
    when 'photo'
      return false if embed[:url].blank?

      @card.embed_url        = (url + embed[:url]).to_s
      @card.image_remote_url = (url + embed[:url]).to_s
      @card.width            = embed[:width].presence  || 0
      @card.height           = embed[:height].presence || 0
    when 'video'
      @card.width            = embed[:width].presence  || 0
      @card.height           = embed[:height].presence || 0
      @card.html             = Sanitize.fragment(embed[:html], Sanitize::Config::MASTODON_OEMBED)
      @card.image_remote_url = (url + embed[:thumbnail_url]).to_s if embed[:thumbnail_url].present?
    when 'rich'
      # Most providers rely on <script> tags, which is a no-no
      return false
    end

    @card.save_with_optional_image!
  end

  def attempt_opengraph
    return if html.nil?

    link_details_extractor = LinkDetailsExtractor.new(@url, @html, @html_charset)
    provider = PreviewCardProvider.matching_domain(Addressable::URI.parse(link_details_extractor.canonical_url).normalized_host)
    linked_account = ResolveAccountService.new.call(link_details_extractor.author_account, suppress_errors: true) if link_details_extractor.author_account.present? && provider&.trendable?

    @card = PreviewCard.find_or_initialize_by(url: link_details_extractor.canonical_url) if link_details_extractor.canonical_url != @card.url
    @card.assign_attributes(link_details_extractor.to_preview_card_attributes)
    @card.author_account = linked_account
    @card.save_with_optional_image! unless @card.title.blank? && @card.html.blank?
  end
end
