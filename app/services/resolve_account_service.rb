# frozen_string_literal: true

class ResolveAccountService < BaseService
  include DomainControlHelper
  include Redisable
  include Lockable

  # Find or create an account record for a remote user. When creating,
  # look up the user's webfinger and fetch ActivityPub data
  # @param [String, Account] uri URI in the username@domain format or account record
  # @param [Hash] options
  # @option options [Boolean] :redirected Do not follow further Webfinger redirects
  # @option options [Boolean] :skip_webfinger Do not attempt any webfinger query or refreshing account data
  # @option options [Boolean] :skip_cache Get the latest data from origin even if cache is not due to update yet
  # @option options [Boolean] :suppress_errors When failing, return nil instead of raising an error
  # @return [Account]
  def call(uri, options = {})
    return if uri.blank?

    process_options!(uri, options)

    # First of all we want to check if we've got the account
    # record with the URI already, and if so, we can exit early

    return if domain_not_allowed?(@domain)

    @account ||= Account.find_remote(@username, @domain)

    return @account if @account&.local? || @domain.nil? || !webfinger_update_due?

    # At this point we are in need of a Webfinger query, which may
    # yield us a different username/domain through a redirect
    process_webfinger!(@uri)
    @domain = nil if TagManager.instance.local_domain?(@domain)

    # Because the username/domain pair may be different than what
    # we already checked, we need to check if we've already got
    # the record with that URI, again

    return if domain_not_allowed?(@domain)

    @account ||= Account.find_remote(@username, @domain)

    if gone_from_origin? && not_yet_deleted?
      queue_deletion!
      return
    end

    return @account if @account&.local? || gone_from_origin? || !webfinger_update_due?

    # Now it is certain, it is definitely a remote account, and it
    # either needs to be created, or updated from fresh data

    fetch_account!
  rescue Webfinger::Error => e
    Rails.logger.debug { "Webfinger query for #{@uri} failed: #{e}" }
    raise unless @options[:suppress_errors]
  end

  private

  def process_options!(uri, options)
    @options = { suppress_errors: true }.merge(options)

    if uri.is_a?(Account)
      @account  = uri
      @username = @account.username
      @domain   = @account.domain
    else
      @username, @domain = uri.strip.gsub(/\A@/, '').split('@')
    end

    @domain = if TagManager.instance.local_domain?(@domain)
                nil
              else
                TagManager.instance.normalize_domain(@domain)
              end

    @uri = [@username, @domain].compact.join('@')
  end

  def process_webfinger!(uri)
    @webfinger = Webfinger.new("acct:#{uri}").perform
    confirmed_username, confirmed_domain = split_acct(@webfinger.subject)

    if confirmed_username.casecmp(@username).zero? && confirmed_domain.casecmp(@domain).zero?
      @username = confirmed_username
      @domain   = confirmed_domain
      return
    end

    # Account doesn't match, so it may have been redirected
    @webfinger = Webfinger.new("acct:#{confirmed_username}@#{confirmed_domain}").perform
    @username, @domain = split_acct(@webfinger.subject)

    raise Webfinger::RedirectError, "Too many webfinger redirects for URI #{uri} (stopped at #{@username}@#{@domain})" unless confirmed_username.casecmp(@username).zero? && confirmed_domain.casecmp(@domain).zero?
  rescue Webfinger::GoneError
    @gone = true
  end

  def split_acct(acct)
    acct.delete_prefix('acct:').split('@').tap do |parts|
      raise Webfinger::Error, 'Webfinger response is missing user or host value' unless parts.size == 2
    end
  end

  def fetch_account!
    with_redis_lock("resolve:#{@username}@#{@domain}") do
      @account = ActivityPub::FetchRemoteAccountService.new.call(actor_url, suppress_errors: @options[:suppress_errors])
    end

    @account
  end

  def webfinger_update_due?
    return false if @options[:check_delivery_availability] && !DeliveryFailureTracker.available?(@domain)
    return false if @options[:skip_webfinger]

    @options[:skip_cache] || @account.nil? || @account.possibly_stale?
  end

  def actor_url
    @actor_url ||= @webfinger.self_link_href
  end

  def gone_from_origin?
    @gone
  end

  def not_yet_deleted?
    @account.present? && !@account.local?
  end

  def queue_deletion!
    @account.suspend!(origin: :remote)
    AccountDeletionWorker.perform_async(@account.id, { 'reserve_username' => false, 'skip_activitypub' => true })
  end
end
