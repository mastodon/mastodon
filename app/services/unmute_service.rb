# frozen_string_literal: true

class UnmuteService < BaseService
  def call(account, target_account)
    return unless account.muting?(target_account)

    account.unmute!(target_account)

    process_merges(account, target_account) if account.following?(target_account)
  end

  private

  def process_merges(account, target_account)
    MergeWorker.perform_async(target_account.id, account.id, 'home')

    MergeWorker.push_bulk(mergeable_list_ids(account, target_account)) do |list_id|
      [target_account.id, list_id, 'list']
    end
  end

  def mergeable_list_ids(account, target_account)
    account
      .owned_lists
      .with_list_account(target_account)
      .pluck(:id)
  end
end
