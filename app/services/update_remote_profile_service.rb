# frozen_string_literal: true

class UpdateRemoteProfileService < BaseService
  POCO_NS = 'http://portablecontacts.net/spec/1.0'
  DFRN_NS = 'http://purl.org/macgirvin/dfrn/1.0'

  def call(xml, account, resubscribe = false)
    author_xml = xml.at_xpath('./xmlns:author') || xml.at_xpath('./dfrn:owner', dfrn: DFRN_NS)
    hub_link   = xml.at_xpath('./xmlns:link[@rel="hub"]')

    unless author_xml.nil?
      account.display_name      = author_xml.at_xpath('./poco:displayName', poco: POCO_NS).content unless author_xml.at_xpath('./poco:displayName', poco: POCO_NS).nil?
      account.note              = author_xml.at_xpath('./poco:note', poco: POCO_NS).content unless author_xml.at_xpath('./poco:note').nil?
      account.avatar_remote_url = author_xml.at_xpath('./xmlns:link[@rel="avatar"]')['href'] unless author_xml.at_xpath('./xmlns:link[@rel="avatar"]').nil? || author_xml.at_xpath('./xmlns:link[@rel="avatar"]')['href'].blank?
    end

    old_hub_url     = account.hub_url
    account.hub_url = hub_link['href'] if !hub_link.nil? && !hub_link['href'].blank? && (hub_link['href'] != old_hub_url)
    account.save!

    SubscribeService.new.call(account) if resubscribe && (account.hub_url != old_hub_url)
  end
end
