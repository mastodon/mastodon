# frozen_string_literal: true

class UnfollowService < BaseService
  include Payloadable
  include Redisable
  include Lockable

  # Unfollow and notify the remote user
  # @param [Account] source_account Where to unfollow from
  # @param [Account] target_account Which to unfollow
  # @param [Hash] options
  # @option [Boolean] :skip_unmerge
  def call(source_account, target_account, options = {})
    @source_account = source_account
    @target_account = target_account
    @options        = options

    with_lock("relationship:#{[source_account.id, target_account.id].sort.join(':')}") do
      unfollow! || undo_follow_request!
    end
  end

  private

  def unfollow!
    follow = Follow.find_by(account: @source_account, target_account: @target_account)

    return unless follow

    follow.destroy!

    create_notification(follow) if !@target_account.local? && @target_account.activitypub?
    create_reject_notification(follow) if @target_account.local? && !@source_account.local? && @source_account.activitypub?
    UnmergeWorker.perform_async(@target_account.id, @source_account.id) unless @options[:skip_unmerge]

    follow
  end

  def undo_follow_request!
    follow_request = FollowRequest.find_by(account: @source_account, target_account: @target_account)

    return unless follow_request

    follow_request.destroy!

    create_notification(follow_request) unless @target_account.local?

    follow_request
  end

  def create_notification(follow)
    ActivityPub::DeliveryWorker.perform_async(build_json(follow), follow.account_id, follow.target_account.inbox_url)
  end

  def create_reject_notification(follow)
    ActivityPub::DeliveryWorker.perform_async(build_reject_json(follow), follow.target_account_id, follow.account.inbox_url)
  end

  def build_json(follow)
    Oj.dump(serialize_payload(follow, ActivityPub::UndoFollowSerializer))
  end

  def build_reject_json(follow)
    Oj.dump(serialize_payload(follow, ActivityPub::RejectFollowSerializer))
  end
end
