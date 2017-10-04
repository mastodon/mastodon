# frozen_string_literal: true

class ActivityPub::FetchRemoteAccountService < BaseService
  include JsonLdHelper

  # Should be called when uri has already been checked for locality
  # Does a WebFinger roundtrip on each call
  def call(uri, id: true, prefetched_body: nil)
    @json = if prefetched_body.nil?
              fetch_resource(uri, id)
            else
              body_to_json(prefetched_body)
            end

    return unless supported_context? && expected_type?

    @uri      = @json['id']
    @username = @json['preferredUsername']
    @domain   = Addressable::URI.parse(@uri).normalized_host

    return unless verified_webfinger?

    ActivityPub::ProcessAccountService.new.call(@username, @domain, @json)
  rescue Oj::ParseError
    nil
  end

  private

  def verified_webfinger?
    webfinger                            = Goldfinger.finger("acct:#{@username}@#{@domain}")
    confirmed_username, confirmed_domain = split_acct(webfinger.subject)

    return webfinger.link('self')&.href == @uri if @username.casecmp(confirmed_username).zero? && @domain.casecmp(confirmed_domain).zero?

    webfinger                            = Goldfinger.finger("acct:#{confirmed_username}@#{confirmed_domain}")
    @username, @domain                   = split_acct(webfinger.subject)
    self_reference                       = webfinger.link('self')

    return false unless @username.casecmp(confirmed_username).zero? && @domain.casecmp(confirmed_domain).zero?
    return false if self_reference&.href != @uri

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

  def expected_type?
    @json['type'] == 'Person'
  end
end
