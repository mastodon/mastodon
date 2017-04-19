# frozen_string_literal: true

class FollowRemoteAccountService < BaseService
  include OStatus2::MagicKey

  DFRN_NS = 'http://purl.org/macgirvin/dfrn/1.0'

  # Find or create a local account for a remote user.
  # When creating, look up the user's webfinger and fetch all
  # important information from their feed
  # @param [String] uri User URI in the form of username@domain
  # @return [Account]
  def call(uri)
    username, domain = uri.split('@')

    return Account.find_local(username) if TagManager.instance.local_domain?(domain)

    account = Account.find_remote(username, domain)
    return account unless account_needs_webfinger_update?(account)

    Rails.logger.debug "Looking up webfinger for #{uri}"

    data = Goldfinger.finger("acct:#{uri}")

    raise Goldfinger::Error, 'Missing resource links' if data.link('http://schemas.google.com/g/2010#updates-from').nil? || data.link('salmon').nil? || data.link('http://webfinger.net/rel/profile-page').nil? || data.link('magic-public-key').nil?

    confirmed_username, confirmed_domain = data.subject.gsub(/\Aacct:/, '').split('@')

    return Account.find_local(confirmed_username) if TagManager.instance.local_domain?(confirmed_domain)

    confirmed_account = Account.find_remote(confirmed_username, confirmed_domain)
    if confirmed_account.nil?
      Rails.logger.debug "Creating new remote account for #{uri}"

      domain_block = DomainBlock.find_by(domain: domain)
      account = Account.new(username: confirmed_username, domain: confirmed_domain)
      account.suspended   = true if domain_block && domain_block.suspend?
      account.silenced    = true if domain_block && domain_block.silence?
      account.private_key = nil
    else
      account = confirmed_account
    end

    account.last_webfingered_at = Time.now.utc

    account.remote_url  = data.link('http://schemas.google.com/g/2010#updates-from').href
    account.salmon_url  = data.link('salmon').href
    account.url         = data.link('http://webfinger.net/rel/profile-page').href
    account.public_key  = magic_key_to_pem(data.link('magic-public-key').href)

    body, xml = get_feed(account.remote_url)
    hubs      = get_hubs(xml)

    account.uri     = get_account_uri(xml)
    account.hub_url = hubs.first.attribute('href').value

    account.save!
    get_profile(body, account)

    account
  end

  private

  def account_needs_webfinger_update?(account)
    account&.last_webfingered_at.nil? || account.last_webfingered_at <= 1.day.ago
  end

  def get_feed(url)
    response = http_client.get(Addressable::URI.parse(url))
    [response.to_s, Nokogiri::XML(response)]
  end

  def get_hubs(xml)
    hubs = xml.xpath('//xmlns:link[@rel="hub"]')
    raise Goldfinger::Error, 'No PubSubHubbub hubs found' if hubs.empty? || hubs.first.attribute('href').nil?
    hubs
  end

  def get_account_uri(xml)
    author_uri = xml.at_xpath('/xmlns:feed/xmlns:author/xmlns:uri')

    if author_uri.nil?
      owner = xml.at_xpath('/xmlns:feed').at_xpath('./dfrn:owner', dfrn: DFRN_NS)
      author_uri = owner.at_xpath('./xmlns:uri') unless owner.nil?
    end

    raise Goldfinger::Error, 'Author URI could not be found' if author_uri.nil?
    author_uri.content
  end

  def get_profile(body, account)
    RemoteProfileUpdateWorker.perform_async(account.id, body.force_encoding('UTF-8'), false)
  end

  def http_client
    HTTP.timeout(:per_operation, write: 20, connect: 20, read: 50)
  end
end
