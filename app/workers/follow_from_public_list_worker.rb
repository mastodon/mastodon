# frozen_string_literal: true

class FollowFromPublicListWorker
  include Sidekiq::Worker

  def perform(into_account_id, list_id)
    list = List.where(type: :public_list).find(list_id)
    into_account = Account.find(into_account_id)

    list.accounts.find_each do |target_account|
      FollowService.new.call(into_account, target_account)
    rescue
      # Skip past disallowed follows
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
