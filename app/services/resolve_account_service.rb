# frozen_string_literal: true

require_relative '../models/account'

class ResolveAccountService < BaseService
  include JsonLdHelper

  # Find or create a local account for a remote user.
  # When creating, look up the user's webfinger and fetch all
  # important information from their feed
  # @param [String, Account] uri User URI in the form of username@domain
  # @param [Hash] options
  # @return [Account]
  def call(uri, options = {})
    @options = options

    if uri.is_a?(Account)
      @account  = uri
      @username = @account.username
      @domain   = @account.domain
      uri       = "#{@username}@#{@domain}"

      return @account if @account.local? || !webfinger_update_due?
    else
      @username, @domain = uri.split('@')

      return Account.find_local(@username) if TagManager.instance.local_domain?(@domain)

      @account = Account.find_remote(@username, @domain)

      return @account unless webfinger_update_due?
    end

    Rails.logger.debug "Looking up webfinger for #{uri}"

    @webfinger = Goldfinger.finger("acct:#{uri}")

    confirmed_username, confirmed_domain = @webfinger.subject.gsub(/\Aacct:/, '').split('@')

    if confirmed_username.casecmp(@username).zero? && confirmed_domain.casecmp(@domain).zero?
      @username = confirmed_username
      @domain   = confirmed_domain
    elsif options[:redirected].nil?
      return call("#{confirmed_username}@#{confirmed_domain}", options.merge(redirected: true))
    else
      Rails.logger.debug 'Requested and returned acct URIs do not match'
      return
    end

    return Account.find_local(@username) if TagManager.instance.local_domain?(@domain)
    return unless activitypub_ready?

    RedisLock.acquire(lock_options) do |lock|
      if lock.acquired?
        @account = Account.find_remote(@username, @domain)

        next unless @account.nil? || @account.activitypub?

        handle_activitypub
      else
        raise Mastodon::RaceConditionError
      end
    end

    @account
  rescue Goldfinger::Error => e
    Rails.logger.debug "Webfinger query for #{uri} unsuccessful: #{e}"
    nil
  end

  private

  def webfinger_update_due?
    @account.nil? || ((!@options[:skip_webfinger] || @account.ostatus?) && @account.possibly_stale?)
  end

  def activitypub_ready?
    !@webfinger.link('self').nil? && ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].include?(@webfinger.link('self').type)
  end

  def handle_activitypub
    return if actor_json.nil?

    @account = ActivityPub::ProcessAccountService.new.call(@username, @domain, actor_json)
  rescue Oj::ParseError
    nil
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
