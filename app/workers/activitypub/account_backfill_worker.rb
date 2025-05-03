# frozen_string_literal: true

class ActivityPub::AccountBackfillWorker
  include Sidekiq::Worker
  include ExponentialBackoff

  def perform(account_id, options = {})
    account = Account.find(account_id)
    return if account.local?

    ActivityPub::AccountBackfillService.new.call(account, **options.deep_symbolize_keys)
  end
end
