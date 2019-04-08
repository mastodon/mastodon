# frozen_string_literal: true

class MuteWorker
  include Sidekiq::Worker

  def perform(account_id, target_account_id)
    FeedManager.instance.clear_from_timelines(
      Account.find(account_id),
      Account.find(target_account_id)
    )
  end
end
