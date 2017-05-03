# frozen_string_literal: true

class FetchRemoteStatusService < BaseService
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
    Rails.logger.debug "Processing Atom for remote status at #{url}"

    xml = Nokogiri::XML(body)
    xml.encoding = 'utf-8'

    account = extract_author(url, xml)

    return nil if account.nil?

    statuses = ProcessFeedService.new.call(body, account)

    statuses.first
  end

  def extract_author(url, xml)
    url_parts = Addressable::URI.parse(url).normalize
    domain    = url_parts.host

    follow_remote_account_service = FollowRemoteAccountService.new
    uri = follow_remote_account_service.acct_uri_from_atom(xml)

    return nil if uri.nil?

    Rails.logger.debug "Going to webfinger #{uri}"

    account = follow_remote_account_service.call(uri)

    # If the author's confirmed URLs do not match the domain of the URL
    # we are reading this from, abort
    return nil unless confirmed_domain?(domain, account)

    account
  rescue Nokogiri::XML::XPath::SyntaxError
    Rails.logger.debug 'Invalid XML or missing namespace'
    nil
  end

  def confirmed_domain?(domain, account)
    domain.casecmp(account.domain).zero? || domain.casecmp(Addressable::URI.parse(account.remote_url).normalize.host).zero?
  end
end
