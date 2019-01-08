# frozen_string_literal: true

class FetchRemoteAccountService < BaseService
  include AuthorExtractor

  def call(url, prefetched_body = nil, protocol = :ostatus)
    if prefetched_body.nil?
      resource_url, resource_options, protocol = FetchAtomService.new.call(url)
    else
      resource_url     = url
      resource_options = { prefetched_body: prefetched_body }
    end

    case protocol
    when :ostatus
      process_atom(resource_url, **resource_options)
    when :activitypub
      ActivityPub::FetchRemoteAccountService.new.call(resource_url, **resource_options)
    end
  end

  private

  def process_atom(url, prefetched_body:)
    xml = Nokogiri::XML(prefetched_body)
    xml.encoding = 'utf-8'

    account = author_from_xml(xml.at_xpath('/xmlns:feed', xmlns: OStatus::TagManager::XMLNS), false)

    UpdateRemoteProfileService.new.call(xml, account) if account.present? && trusted_domain?(url, account)

    account
  rescue TypeError
    Rails.logger.debug "Unparseable URL given: #{url}"
    nil
  rescue Nokogiri::XML::XPath::SyntaxError
    Rails.logger.debug 'Invalid XML or missing namespace'
    nil
  end

  def trusted_domain?(url, account)
    domain = Addressable::URI.parse(url).normalized_host
    domain.casecmp(account.domain).zero? || domain.casecmp(Addressable::URI.parse(account.remote_url.presence || account.uri).normalized_host).zero?
  end
end
