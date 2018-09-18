# frozen_string_literal: true

class VerifyLinkService < BaseService
  def call(field)
    @link_back = ActivityPub::TagManager.instance.url_for(field.account)
    @url       = field.value

    perform_request!

    return unless link_back_present?

    field.mark_verified!
    field.account.save!
  rescue HTTP::Error, Addressable::URI::InvalidURIError, Mastodon::HostValidationError, Mastodon::LengthValidationError => e
    Rails.logger.debug "Error fetching link #{@url}: #{e}"
    nil
  end

  private

  def perform_request!
    @body = Request.new(:get, @url).add_headers('Accept' => 'text/html').perform do |res|
      res.code != 200 ? nil : res.body_with_limit
    end
  end

  def link_back_present?
    return false if @body.empty?

    Nokogiri::HTML(@body).xpath('//a[@rel="me"]|//link[@rel="me"]').any? { |link| link['href'] == @link_back }
  end
end
