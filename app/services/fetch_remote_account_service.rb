# frozen_string_literal: true

class FetchRemoteAccountService < BaseService
  def call(url, prefetched_body = nil)
    if prefetched_body.nil?
      atom_url, body = FetchAtomService.new.call(url)
    else
      atom_url = url
      body     = prefetched_body
    end

    return nil if atom_url.nil?
    process_atom(atom_url, body)
  end

  private

  def process_atom(url, body)
    xml = Nokogiri::XML(body)
    xml.encoding = 'utf-8'

    email = xml.at_xpath('//xmlns:author/xmlns:email').try(:content)
    if email.nil?
      url_parts = Addressable::URI.parse(url).normalize
      username  = xml.at_xpath('//xmlns:author/xmlns:name').try(:content)
      domain    = url_parts.host
    else
      username, domain = email.split('@')
    end

    return nil if username.nil? || domain.nil?

    Rails.logger.debug "Going to webfinger #{username}@#{domain}"

    account = FollowRemoteAccountService.new.call("#{username}@#{domain}")
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
