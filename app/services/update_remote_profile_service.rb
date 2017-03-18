# frozen_string_literal: true

class UpdateRemoteProfileService < BaseService
  def call(xml, account, resubscribe = false)
    return if xml.nil?

    author_xml = xml.at_xpath('./xmlns:author', xmlns: TagManager::XMLNS) || xml.at_xpath('./dfrn:owner', dfrn: TagManager::DFRN_XMLNS)
    hub_link   = xml.at_xpath('./xmlns:link[@rel="hub"]', xmlns: TagManager::XMLNS)

    unless author_xml.nil?
      account.display_name = author_xml.at_xpath('./poco:displayName', poco: TagManager::POCO_XMLNS).content unless author_xml.at_xpath('./poco:displayName', poco: TagManager::POCO_XMLNS).nil?
      account.note         = author_xml.at_xpath('./poco:note', poco: TagManager::POCO_XMLNS).content unless author_xml.at_xpath('./poco:note', poco: TagManager::POCO_XMLNS).nil?
      account.locked       = author_xml.at_xpath('./mastodon:scope', mastodon: TagManager::MTDN_XMLNS)&.content == 'private'

      unless account.suspended? || DomainBlock.find_by(domain: account.domain)&.reject_media?
        account.avatar_remote_url = author_xml.at_xpath('./xmlns:link[@rel="avatar"]', xmlns: TagManager::XMLNS)['href'] unless author_xml.at_xpath('./xmlns:link[@rel="avatar"]', xmlns: TagManager::XMLNS).nil? || author_xml.at_xpath('./xmlns:link[@rel="avatar"]', xmlns: TagManager::XMLNS)['href'].blank?
        account.header_remote_url = author_xml.at_xpath('./xmlns:link[@rel="header"]', xmlns: TagManager::XMLNS)['href'] unless author_xml.at_xpath('./xmlns:link[@rel="header"]', xmlns: TagManager::XMLNS).nil? || author_xml.at_xpath('./xmlns:link[@rel="header"]', xmlns: TagManager::XMLNS)['href'].blank?
      end
    end

    old_hub_url     = account.hub_url
    account.hub_url = hub_link['href'] if !hub_link.nil? && !hub_link['href'].blank? && (hub_link['href'] != old_hub_url)

    account.save_with_optional_avatar!

    SubscribeService.new.call(account) if resubscribe && (account.hub_url != old_hub_url)
  end
end
