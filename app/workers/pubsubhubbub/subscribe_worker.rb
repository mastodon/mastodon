# frozen_string_literal: true

class Pubsubhubbub::SubscribeWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(account_id)
    account = Account.find(account_id)
    logger.debug "PuSH re-subscribing to #{account.acct}"
    ::SubscribeService.new.call(account)
  end
end
