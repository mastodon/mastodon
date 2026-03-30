# frozen_string_literal: true

class UnmuteService < BaseService
  def call(account, target_account)
    return unless account.muting?(target_account)

    account.unmute!(target_account)

    if account.following?(target_account)
      MergeWorker.perform_async(target_account.id, account.id, 'home')

      MergeWorker.push_bulk(account.owned_lists.with_list_account(target_account).pluck(:id)) do |list_id|
        [target_account.id, list_id, 'list']
      end
    end
  end
end
