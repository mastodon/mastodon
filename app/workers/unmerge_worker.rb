# frozen_string_literal: true

class UnmergeWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(from_account_id, into_account_id)
    ApplicationRecord.connected_to(role: :primary) do
      @from_account = Account.find(from_account_id)
      @into_account = Account.find(into_account_id)
    end

    ApplicationRecord.connected_to(role: :read, prevent_writes: true) do
      FeedManager.instance.unmerge_from_home(@from_account, @into_account)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
