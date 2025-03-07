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

  def call(status)
    @status = status
    return if @status.with_preview_card?

    @original_url = parse_urls

    return if @original_url.nil?

    @url = @original_url.to_s

    @card = FetchLinkCardForURLService.new.call(@url)

    attach_card if @card&.persisted?
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.debug { "Error attching preview card for #{@original_url}: #{e}" }
    nil
  end

  private

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
             document = Nokogiri::HTML5(@status.text)
             links = document.css('a')

             links.filter_map { |a| Addressable::URI.parse(a['href']) unless skip_link?(a) }.filter_map(&:normalize)
           end

    urls.reject { |uri| bad_url?(uri) }.first
  end

  def bad_url?(uri)
    # Avoid local instance URLs and invalid URLs
    uri.host.blank? || TagManager.instance.local_url?(uri.to_s) || !%w(http https).include?(uri.scheme)
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
end
