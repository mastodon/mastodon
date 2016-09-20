class FollowRemoteAccountService < BaseService
  # Find or create a local account for a remote user.
  # When creating, look up the user's webfinger and fetch all
  # important information from their feed
  # @param [String] uri User URI in the form of username@domain
  # @return [Account]
  def call(uri)
    username, domain = uri.split('@')

    return Account.find_local(username) if domain == Rails.configuration.x.local_domain || domain.nil?

    account = Account.find_remote(username, domain)

    return account unless account.nil?

    Rails.logger.debug "Creating new remote account for #{uri}"
    account = Account.new(username: username, domain: domain)

    data = Goldfinger.finger("acct:#{uri}")

    account.remote_url  = data.link('http://schemas.google.com/g/2010#updates-from').href
    account.salmon_url  = data.link('salmon').href
    account.url         = data.link('http://webfinger.net/rel/profile-page').href
    account.public_key  = magic_key_to_pem(data.link('magic-public-key').href)
    account.private_key = nil

    feed = get_feed(account.remote_url)
    hubs = feed.xpath('//xmlns:link[@rel="hub"]')

    if hubs.empty? || hubs.first.attribute('href').nil?
      raise Goldfinger::Error, "No PubSubHubbub hubs found"
    end

    if feed.at_xpath('/xmlns:feed/xmlns:author/xmlns:uri').nil?
      raise Goldfinger::Error, "No author URI found"
    end

    account.uri     = feed.at_xpath('/xmlns:feed/xmlns:author/xmlns:uri').content
    account.hub_url = hubs.first.attribute('href').value

    get_profile(feed, account)
    account.save!

    return account
  end

  private

  def get_feed(url)
    response = http_client.get(Addressable::URI.parse(url))
    Nokogiri::XML(response)
  end

  def get_profile(xml, account)
    author = xml.at_xpath('/xmlns:feed/xmlns:author')
    update_remote_profile_service.(author, account)
  end

  def magic_key_to_pem(magic_key)
    _, modulus, exponent = magic_key.split('.')
    modulus, exponent = [modulus, exponent].map { |n| Base64.urlsafe_decode64(n).bytes.inject(0) { |num, byte| (num << 8) | byte } }

    key   = OpenSSL::PKey::RSA.new
    key.n = modulus
    key.e = exponent

    key.to_pem
  end

  def update_remote_profile_service
    @update_remote_profile_service ||= UpdateRemoteProfileService.new
  end

  def http_client
    HTTP.timeout(:per_operation, write: 20, connect: 20, read: 50)
  end
end

