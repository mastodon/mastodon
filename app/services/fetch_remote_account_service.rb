# frozen_string_literal: true

class FetchRemoteAccountService < BaseService
  include AuthorExtractor

  def call(url, prefetched_body = nil, protocol = :ostatus)
    if prefetched_body.nil?
      resource_url, body, protocol = FetchAtomService.new.call(url)
    else
      resource_url = url
      body         = prefetched_body
    end

    case protocol
    when :ostatus
      process_atom(resource_url, body)
    when :activitypub
      ActivityPub::FetchRemoteAccountService.new.call(resource_url, body)
    end
  end

  private

  def process_atom(url, body)
    xml = Nokogiri::XML(body)
    xml.encoding = 'utf-8'

    account = author_from_xml(xml.at_xpath('/xmlns:feed', xmlns: TagManager::XMLNS), false)

    UpdateRemoteProfileService.new.call(xml, account) unless account.nil?

    account
  rescue TypeError
    Rails.logger.debug "Unparseable URL given: #{url}"
    nil
  rescue Nokogiri::XML::XPath::SyntaxError
    Rails.logger.debug 'Invalid XML or missing namespace'
    nil
  end
end
