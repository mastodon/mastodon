# frozen_string_literal: true

class UnmergeWorker
  include Sidekiq::Worker
  include DatabaseHelper

  sidekiq_options queue: 'pull'

  def perform(from_account_id, into_account_id)
    with_primary do
      @from_account = Account.find(from_account_id)
      @into_account = Account.find(into_account_id)
    end

    with_read_replica do
      FeedManager.instance.unmerge_from_home(@from_account, @into_account)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
