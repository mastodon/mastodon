# frozen_string_literal: true

class FamiliarFollowersPresenter
  class Result < ActiveModelSerializers::Model
    attributes :id, :accounts
  end

  def initialize(accounts, current_account_id)
    @accounts           = accounts
    @current_account_id = current_account_id
  end

  def accounts
    map = Follow.includes(account: :account_stat).where(target_account_id: @accounts.map(&:id)).where(account_id: Follow.where(account_id: @current_account_id).joins(:target_account).merge(Account.where(hide_collections: [nil, false])).select(:target_account_id)).group_by(&:target_account_id)
    @accounts.map { |account| Result.new(id: account.id, accounts: (account.hide_collections? ? [] : (map[account.id] || [])).map(&:account)) }
  end
end
