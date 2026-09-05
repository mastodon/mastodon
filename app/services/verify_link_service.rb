# frozen_string_literal: true

class VerifyLinkService < BaseService
  def call(field)
    @link_back = ActivityPub::TagManager.instance.url_for(field.account)
    @url       = field.value_for_verification

    perform_request!

    return unless link_back_present?

    field.mark_verified!
  rescue *Mastodon::HTTP_CONNECTION_ERRORS, Addressable::URI::InvalidURIError, Mastodon::HostValidationError, Mastodon::LengthValidationError, IPAddr::AddressFamilyError => e
    Rails.logger.debug { "Error fetching link #{@url}: #{e}" }
    nil
  end

  private

  def perform_request!
    Request.new(:get, @url).add_headers('Accept' => 'text/html').perform do |res|
      next unless res.code == 200

      @body         = res.truncated_body
      @link_headers = res.headers.get('Link')
    end
  end

  def link_back_present?
    link_back_in_headers? || link_back_in_body?
  end

  # Honours RFC 8288 `Link` headers such as `<https://example.com/@alice>; rel="me"`,
  # so a site can verify without carrying a rel="me" anchor in its markup.
  def link_back_in_headers?
    Array(@link_headers).any? do |header_value|
      LinkHeader.parse(header_value).links.any? do |link|
        rel_me?(link) && matches_link_back?(link.href)
      end
    end
  end

  # The rel parameter is a whitespace-separated list of relation types compared
  # case-insensitively. Single quotes are not valid in Link headers but do show
  # up in the wild, so tolerate them.
  def rel_me?(link)
    link.attr_pairs.any? do |attribute_name, attribute_value|
      next false unless attribute_name.casecmp?('rel')

      attribute_value.delete_prefix("'").delete_suffix("'").split.any? { |relation_type| relation_type.casecmp?('me') }
    end
  end

  def link_back_in_body?
    return false if @body.blank?

    links = Nokogiri::HTML5(@body).xpath('(//a|//link)[@rel][nokogiri:link_rel_include(@rel, "me")]', NokogiriHandler)

    if links.any? { |link| matches_link_back?(link['href']) }
      true
    elsif links.empty?
      false
    else
      link_redirects_back?(links.first['href'])
    end
  end

  def matches_link_back?(href)
    href&.downcase == @link_back.downcase
  end

  def link_redirects_back?(test_url)
    return false if test_url.blank?

    redirect_to_url = Request.new(:head, test_url, follow: false).perform do |res|
      res.headers['Location']
    end

    redirect_to_url == @link_back
  end
end
