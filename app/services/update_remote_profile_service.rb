# frozen_string_literal: true

class UpdateRemoteProfileService < BaseService
  POCO_NS = 'http://portablecontacts.net/spec/1.0'

  def call(author_xml, account)
    return if author_xml.nil?

    account.display_name = if author_xml.at_xpath('./poco:displayName', poco: POCO_NS).nil?
                             account.username
                           else
                             author_xml.at_xpath('./poco:displayName', poco: POCO_NS).content
                           end

    unless author_xml.at_xpath('./poco:note').nil?
      account.note = author_xml.at_xpath('./poco:note', poco: POCO_NS).content
    end

    unless author_xml.at_xpath('./xmlns:link[@rel="avatar"]').nil?
      account.avatar_remote_url = author_xml.at_xpath('./xmlns:link[@rel="avatar"]').attribute('href').value
    end

    account.save!
  end
end
