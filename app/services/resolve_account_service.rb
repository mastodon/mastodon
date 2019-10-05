# frozen_string_literal: true

class ResolveAccountService < BaseService
  include JsonLdHelper
  include DomainControlHelper

  class WebfingerRedirectError < StandardError; end

  # Find or create an account record for a remote user. When creating,
  # look up the user's webfinger and fetch ActivityPub data
  # @param [String, Account] uri URI in the username@domain format or account record
  # @param [Hash] options
  # @option options [Boolean] :redirected Do not follow further Webfinger redirects
  # @option options [Boolean] :skip_webfinger Do not attempt to refresh account data
  # @return [Account]
  def call(uri, options = {})
    return if uri.blank?

    process_options!(uri, options)

    # First of all we want to check if we've got the account
    # record with the URI already, and if so, we can exit early

    return if domain_not_allowed?(@domain)

    @account ||= Account.find_remote(@username, @domain)

    return @account if @account&.local? || !webfinger_update_due?

    # At this point we are in need of a Webfinger query, which may
    # yield us a different username/domain through a redirect

    process_webfinger!(@uri)

    # Because the username/domain pair may be different than what
    # we already checked, we need to check if we've already got
    # the record with that URI, again

    return if domain_not_allowed?(@domain)

    @account ||= Account.find_remote(@username, @domain)

    return @account if @account&.local? || !webfinger_update_due?

    # Now it is certain, it is definitely a remote account, and it
    # either needs to be created, or updated from fresh data

    process_account!
  rescue Goldfinger::Error, WebfingerRedirectError, Oj::ParseError => e
    Rails.logger.debug "Webfinger query for #{@uri} failed: #{e}"
    nil
  end

  private

  def process_options!(uri, options)
    @options = options

    if uri.is_a?(Account)
      @account  = uri
      @username = @account.username
      @domain   = @account.domain
    else
      @username, @domain = uri.split('@')
    end

    @domain = begin
      if TagManager.instance.local_domain?(@domain)
        nil
      else
        TagManager.instance.normalize_domain(@domain)
      end
    end

    @uri = [@username, @domain].compact.join('@')
  end

  def process_webfinger!(uri, redirected = false)
    @webfinger                           = Goldfinger.finger("acct:#{uri}")
    confirmed_username, confirmed_domain = @webfinger.subject.gsub(/\Aacct:/, '').split('@')

    if confirmed_username.casecmp(@username).zero? && confirmed_domain.casecmp(@domain).zero?
      @username = confirmed_username
      @domain   = confirmed_domain
      @uri      = uri
    elsif !redirected
      return process_webfinger!("#{confirmed_username}@#{confirmed_domain}", true)
    else
      raise WebfingerRedirectError, "The URI #{uri} tries to hijack #{@username}@#{@domain}"
    end

    @domain = nil if TagManager.instance.local_domain?(@domain)
  end

  def process_account!
    return unless activitypub_ready?

    RedisLock.acquire(lock_options) do |lock|
      if lock.acquired?
        @account = Account.find_remote(@username, @domain)

        next if (@account.present? && !@account.activitypub?) || actor_json.nil?

        @account = ActivityPub::ProcessAccountService.new.call(@username, @domain, actor_json)
      else
        raise Mastodon::RaceConditionError
      end
    end

    @account
  end

  def webfinger_update_due?
    @account.nil? || ((!@options[:skip_webfinger] || @account.ostatus?) && @account.possibly_stale?)
  end

  def activitypub_ready?
    !@webfinger.link('self').nil? && ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].include?(@webfinger.link('self').type)
  end

  def actor_url
    @actor_url ||= @webfinger.link('self').href
  end

  def actor_json
    return @actor_json if defined?(@actor_json)

    json        = fetch_resource(actor_url, false)
    @actor_json = supported_context?(json) && equals_or_includes_any?(json['type'], ActivityPub::FetchRemoteAccountService::SUPPORTED_TYPES) ? json : nil
  end

  def lock_options
    { redis: Redis.current, key: "resolve:#{@username}@#{@domain}" }
  end
end
