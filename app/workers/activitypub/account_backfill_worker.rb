# frozen_string_literal: true

class ActivityPub::AccountBackfillWorker
  include Sidekiq::Worker
  include ExponentialBackoff

  def perform(account_id, options = {})
    ActivityPub::AccountBackfillService.new.call(Account.find(account_id), **options.deep_symbolize_keys)
  end
end
