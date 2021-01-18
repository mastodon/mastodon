# frozen_string_literal: true

class ActivityPub::Activity::Block < ActivityPub::Activity
  def perform
    target_account = account_from_uri(object_uri)

    return if target_account.nil? || !target_account.local?

    if @account.blocking?(target_account)
      @account.block_relationships.find_by(target_account: target_account).update(uri: @json['id']) if @json['id'].present?
      return
    end

    UnfollowService.new.call(@account, target_account) if @account.following?(target_account)
    UnfollowService.new.call(target_account, @account) if target_account.following?(@account)
    RejectFollowService.new.call(target_account, @account) if target_account.requested?(@account)

    unless delete_arrived_first?(@json['id'])
      BlockWorker.perform_async(@account.id, target_account.id)
      @account.block!(target_account, uri: @json['id'])
    end
  end
end
