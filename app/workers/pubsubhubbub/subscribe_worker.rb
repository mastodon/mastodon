# frozen_string_literal: true

class Pubsubhubbub::SubscribeWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', retry: 10, unique: :until_executed

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

  def perform(account_id)
    account = Account.find(account_id)
    logger.debug "PuSH re-subscribing to #{account.acct}"
    ::SubscribeService.new.call(account)
  end
end
