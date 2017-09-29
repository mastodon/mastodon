# frozen_string_literal: true

class FetchRemoteCustomEmojiIconService < BaseService
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
      ActivityPub::FetchRemoteCustomEmojiIconService.new.call(resource_url, body)
    end
  end

  private

  def process_atom(url, body)
    xml = Nokogiri::XML(body)
    xml.encoding = 'utf-8'

    entry = xml.at_xpath('/xmlns:entry', xmlns: OStatus::TagManager::XMLNS)
    uri = entry.at_xpath('./xmlns:id', xmlns: OStatus::TagManager::XMLNS).content
    href = entry.at_xpath('./xmlns:link[@rel="enclosure"]', xmlns: OStatus::TagManager::XMLNS)['href']

    icon = CustomEmojiIcon.new(uri: uri)
    icon.image_remote_url = href
    icon.save ? icon : nil
  rescue TypeError
    Rails.logger.debug "Unparseable URL given: #{url}"
    nil
  rescue Nokogiri::XML::XPath::SyntaxError
    Rails.logger.debug 'Invalid XML or missing namespace'
    nil
  end
end
