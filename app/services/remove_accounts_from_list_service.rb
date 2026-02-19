# frozen_string_literal: true

class RemoveAccountsFromListService < BaseService
  def call(list, accounts)
    @list = list
    @accounts = accounts

    return if @accounts.empty?

    unmerge_from_list!
    update_list!
  end

  private

  def update_list!
    ListAccount.where(list: @list, account: @accounts).destroy_all
  end

  def unmerge_from_list!
    UnmergeWorker.push_bulk(unmerge_account_ids) do |account_id|
      [account_id, @list.id, 'list']
    end
  end

  def unmerge_account_ids
    ListAccount.where(list: @list, account: @accounts).where.not(follow_id: nil).pluck(:account_id)
  end
end
