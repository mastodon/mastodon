# frozen_string_literal: true

class Import::RelationshipWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 8, dead: false

  def perform(account_id, target_account_uri, relationship, options)
    from_account   = Account.find(account_id)
    target_domain  = domain(target_account_uri)
    target_account = stoplight_wrap_request(target_domain) { ResolveAccountService.new.call(target_account_uri, { check_delivery_availability: true }) }
    options.symbolize_keys!

    return if target_account.nil?

    case relationship
    when 'follow'
      begin
        FollowService.new.call(from_account, target_account, **options)
      rescue ActiveRecord::RecordInvalid
        raise if FollowLimitValidator.limit_for_account(from_account) < from_account.following_count
      end
    when 'unfollow'
      UnfollowService.new.call(from_account, target_account)
    when 'block'
      BlockService.new.call(from_account, target_account)
    when 'unblock'
      UnblockService.new.call(from_account, target_account)
    when 'mute'
      MuteService.new.call(from_account, target_account, **options)
    when 'unmute'
      UnmuteService.new.call(from_account, target_account)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  def domain(uri)
    domain = uri.is_a?(Account) ? uri.domain : uri.split('@')[1]
    TagManager.instance.local_domain?(domain) ? nil : TagManager.instance.normalize_domain(domain)
  end

  def stoplight_wrap_request(domain, &block)
    if domain.present?
      Stoplight("source:#{domain}", &block)
        .with_fallback { nil }
        .with_threshold(1)
        .with_cool_off_time(5.minutes.seconds)
        .with_error_handler { |error, handle| error.is_a?(HTTP::Error) || error.is_a?(OpenSSL::SSL::SSLError) ? handle.call(error) : raise(error) }
        .run
    else
      block.call
    end
  end
end
