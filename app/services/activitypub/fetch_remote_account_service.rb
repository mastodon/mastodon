# frozen_string_literal: true

class ActivityPub::FetchRemoteAccountService < BaseService
  include JsonLdHelper

  def call(uri)
    response = build_request(uri).perform

    return unless response.code == 200

    @json = Oj.load(response.to_s, mode: :strict)

    return unless supported_context?

    @uri      = @json['id']
    @username = @json['preferredUsername']
    @domain   = Addressable::URI.parse(uri).normalized_host

    return unless verified_webfinger?

    @account = Account.find_by(uri: @uri)

    create_account if @account.nil?
    update_account

    @account
  rescue Oj::ParseError
    nil
  end

  private

  def build_request(uri)
    request = Request.new(:get, uri)
    request.add_headers('Accept' => 'application/activity+json')
    request
  end

  def create_account
    @account = Account.new
    @account.username = @username
    @account.domain   = @domain
    @account.uri      = @uri
    @account.save!
  end

  def update_account
    @account.url               = @json['url'] || @uri
    @account.display_name      = @json['name']
    @account.note              = @json['summary']
    @account.avatar_remote_url = @json['icon']                      if @json['icon']
    @account.header_remote_url = @json['image']                     if @json['image']
    @account.public_key        = @json['publicKey']['publicKeyPem'] if @json['publicKey']&.is_a?(Hash)
    @account.save!
  end

  def verified_webfinger?
    webfinger                            = Goldfinger.finger("acct:#{@username}@#{@domain}")
    confirmed_username, confirmed_domain = split_acct(webfinger.subject)

    return true if @username.casecmp(confirmed_username).zero? && @domain.casecmp(confirmed_domain).zero?

    webfinger                            = Goldfinger.finger("acct:#{confirmed_username}@#{confirmed_domain}")
    confirmed_username, confirmed_domain = split_acct(webfinger.subject)
    self_reference                       = webfinger.link('self')

    return false if self_reference&.href != @uri

    @username = confirmed_username
    @domain   = confirmed_domain

    true
  rescue Goldfinger::Error
    false
  end

  def split_acct(acct)
    acct.gsub(/\Aacct:/, '').split('@')
  end

  def supported_context?
    super(@json)
  end
end
