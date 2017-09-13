# frozen_string_literal: true

class Pubsubhubbub::SubscribeWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', retry: 10, unique: :until_executed, dead: false, unique_retry: true

  sidekiq_retry_in do |count|
    case count
    when 0
      30.minutes.seconds
    when 1
      2.hours.seconds
    when 2
      12.hours.seconds
    else
      24.hours.seconds * (count - 2)
    end
  end

  sidekiq_retries_exhausted do |msg, _e|
    account = Account.find(msg['args'].first)
    logger.error "PuSH subscription attempts for #{account.acct} exhausted. Unsubscribing"
    ::UnsubscribeService.new.call(account)
  end

  def perform(account_id)
    account = Account.find(account_id)
    logger.debug "PuSH re-subscribing to #{account.acct}"
    ::SubscribeService.new.call(account)
  rescue => e
    raise e.class, "Subscribe failed for #{account&.acct}: #{e.message}"
  end
end
