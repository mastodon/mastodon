# frozen_string_literal: true

class ActivityPub::Activity::Block < ActivityPub::Activity
  def perform
    target_account = account_from_uri(object_uri)

    return if target_account.nil? || !target_account.local? || delete_arrived_first?(@json['id']) || @account.blocking?(target_account)

    UnfollowService.new.call(target_account, @account) if target_account.following?(@account)
    @account.block!(target_account)
  end
end
