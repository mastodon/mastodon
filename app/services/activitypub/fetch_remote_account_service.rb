# frozen_string_literal: true

class ActivityPub::FetchRemoteAccountService < BaseService
  include JsonLdHelper

  def call(uri)
    response = Request.new(:get, uri).perform

    return unless response.code.successful?

    @json = Oj.load(response.body, mode: :strict)

    return unless supported_context?

    @uri      = @json['id']
    @username = @json['preferredUsername']
    @domain   = Addressable::URI.parse(uri).normalized_host

    return unless verified_webfinger?

    @account = Account.find_by(uri: @uri)

    create_account if @account.nil?
    update_account
  end

  private

  def create_account
    @account = Account.new
    @account.username = @username
    @account.domain   = @domain
    @account.uri      = @uri
    @account.save!
  end

  def update_account
    @account.url               = @json['url']
    @account.display_name      = @json['name']
    @account.note              = @json['summary']
    @account.avatar_remote_url = @json['icon']
    @account.header_remote_url = @json['image']
    @account.public_key        = @json['publicKey']['publicKeyPem']
    @account.save!
  end

  def verified_webfinger?
    webfinger                            = Goldfinger.finger("#{@username}@#{@domain}")
    confirmed_username, confirmed_domain = split_acct(webfinger.subject)

    return true if @username.casecmp(confirmed_username).zero? && @domain.casecmp(confirmed_domain).zero?

    webfinger                            = Goldfinger.finger("#{confirmed_username}@#{confirmed_domain}")
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
