# frozen_string_literal: true

class ActivityPub::Activity::Block < ActivityPub::Activity
  def perform
    target_account = account_from_uri(object_uri)

    return if target_account.nil? || !target_account.local? || @account.blocking?(target_account)

    UnfollowService.new.call(target_account, @account) if target_account.following?(@account)

    @account.block!(target_account, uri: @json['id']) unless delete_arrived_first?(@json['id'])
  end
end
