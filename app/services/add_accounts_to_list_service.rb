# frozen_string_literal: true

class AddAccountsToListService < BaseService
  def call(list, accounts)
    @list = list
    @accounts = accounts

    return if @accounts.empty?

    update_list!
    merge_into_list!
  end

  private

  def update_list!
    ApplicationRecord.transaction do
      @accounts.each do |account|
        @list.accounts << account
      end
    end
  end

  def merge_into_list!
    MergeWorker.push_bulk(merge_account_ids) do |account_id|
      [account_id, @list.id, 'list']
    end
  end

  def merge_account_ids
    ListAccount.where(list: @list, account: @accounts).where.not(follow_id: nil).pluck(:account_id)
  end
end
