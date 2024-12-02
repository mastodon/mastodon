# frozen_string_literal: true

class MuteWorker
  include Sidekiq::Worker
  include DatabaseHelper

  def perform(account_id, target_account_id)
    with_primary do
      @account = Account.find(account_id)
      @target_account = Account.find(target_account_id)
    end

    with_read_replica do
      FeedManager.instance.clear_from_home(@account, @target_account)
      FeedManager.instance.clear_from_lists(@account, @target_account)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
