# frozen_string_literal: true

class ActivityPub::FetchRemoteAccountService < BaseService
  include JsonLdHelper

  # Should be called when uri has already been checked for locality
  # Does a WebFinger roundtrip on each call
  def call(uri)
    @json = fetch_resource(uri)

    return unless supported_context? && expected_type?

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

  def create_account
    @account = Account.new
    @account.username = @username
    @account.domain   = @domain
    @account.uri      = @uri
    @account.save!
  end

  def update_account
    @account.url               = @json['url'] || @uri
    @account.display_name      = @json['name'] || ''
    @account.note              = @json['summary'] || ''
    @account.avatar_remote_url = image_url('icon')
    @account.header_remote_url = image_url('image')
    @account.public_key        = public_key || ''
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

  def image_url(key)
    value = first_of_value(@json[key])

    return if value.nil?
    return @json[key]['url'] if @json[key].is_a?(Hash)

    image = fetch_resource(value)
    image['url'] if image
  end

  def public_key
    value = first_of_value(@json['publicKey'])

    return if value.nil?
    return value['publicKeyPem'] if value.is_a?(Hash)

    key = fetch_resource(value)
    key['publicKeyPem'] if key
  end

  def supported_context?
    super(@json)
  end

  def expected_type?
    @json['type'] == 'Person'
  end
end
