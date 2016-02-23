class FollowRemoteAccountService
  include ApplicationHelper

  def call(uri)
    username, domain = uri.split('@')
    account = Account.where(username: username, domain: domain).first

    if account.nil?
      account = Account.new(username: username, domain: domain)
    elsif account.subscribed?
      return account
    end

    data = Goldfinger.finger("acct:#{uri}")

    account.remote_url  = data.link('http://schemas.google.com/g/2010#updates-from').href
    account.salmon_url  = data.link('salmon').href
    account.url         = data.link('http://webfinger.net/rel/profile-page').href
    account.public_key  = magic_key_to_pem(data.link('magic-public-key').href)
    account.private_key = nil

    account.secret       = SecureRandom.hex
    account.verify_token = SecureRandom.hex

    feed = get_feed(account.remote_url)
    hubs = feed.xpath('//xmlns:link[@rel="hub"]')

    return nil if hubs.empty? || hubs.first.attribute('href').nil? || feed.at_xpath('/xmlns:feed/xmlns:author/xmlns:uri').nil?

    account.uri     = feed.at_xpath('/xmlns:feed/xmlns:author/xmlns:uri').content
    account.hub_url = hubs.first.attribute('href').value

    get_profile(feed, account)
    account.save!

    subscription = account.subscription(subscription_url(account))
    subscription.subscribe

    return account
  rescue Goldfinger::Error, HTTP::Error => e
    nil
  end

  private

  def get_feed(url)
    response = http_client.get(Addressable::URI.parse(url))
    Nokogiri::XML(response)
  end

  def get_profile(xml, account)
    author = xml.at_xpath('/xmlns:feed/xmlns:author')

    if author.at_xpath('./poco:displayName').nil?
      account.display_name = account.username
    else
      account.display_name = author.at_xpath('./poco:displayName').content
    end

    unless author.at_xpath('./poco:note').nil?
      account.note = author.at_xpath('./poco:note').content
    end
  end

  def magic_key_to_pem(magic_key)
    _, modulus, exponent = magic_key.split('.')
    modulus, exponent = [modulus, exponent].map { |n| Base64.urlsafe_decode64(n).bytes.inject(0) { |num, byte| (num << 8) | byte } }

    key   = OpenSSL::PKey::RSA.new
    key.n = modulus
    key.e = exponent

    key.to_pem
  end

  def http_client
    HTTP
  end
end
