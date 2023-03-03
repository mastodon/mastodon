# frozen_string_literal: true

class ActivityPub::MigratedFollowDeliveryWorker < ActivityPub::DeliveryWorker
  def perform(json, source_account_id, inbox_url, old_target_account_id, options = {})
    super(json, source_account_id, inbox_url, options)
    unfollow_old_account!(old_target_account_id)
  end

  private

  def unfollow_old_account!(old_target_account_id)
    old_target_account = Account.find(old_target_account_id)
    UnfollowService.new.call(@source_account, old_target_account, skip_unmerge: true)
  rescue StandardError
    true
  end
end
