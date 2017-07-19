# frozen_string_literal: true

class ActivityPub::Activity::Block < ActivityPub::Activity
  def perform
    target_account = account_from_uri(object_uri)

    return unless target_account.local?

    UnfollowService.new.call(target_account, @account) if target_account.following?(@account)
    @account.block!(target_account)
  end
end
