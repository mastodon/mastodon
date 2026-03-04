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

    with_redis_lock("relationship:#{[source_account.id, target_account.id].sort.join(':')}") do
      unfollow! || undo_follow_request!
    end
  end

  private

  def unfollow!
    follow = Follow.find_by(account: @source_account, target_account: @target_account)
    return unless follow

    follow.destroy!

    if @target_account.local? && @source_account.remote? && @source_account.activitypub?
      send_reject_follow(follow)
    elsif @target_account.remote? && @target_account.activitypub?
      send_undo_follow(follow)
    end

    unless @options[:skip_unmerge]
      UnmergeWorker.perform_async(@target_account.id, @source_account.id, 'home')
      UnmergeWorker.push_bulk(@source_account.owned_lists.with_list_account(@target_account).pluck(:list_id)) do |list_id|
        [@target_account.id, list_id, 'list']
      end
    end

    follow
  end

  def undo_follow_request!
    follow_request = FollowRequest.find_by(account: @source_account, target_account: @target_account)
    return unless follow_request

    follow_request.destroy!

    send_undo_follow(follow_request) unless @target_account.local?

    follow_request
  end

  def send_undo_follow(follow)
    ActivityPub::DeliveryWorker.perform_async(build_json(follow), follow.account_id, follow.target_account.inbox_url)
  end

  def send_reject_follow(follow)
    ActivityPub::DeliveryWorker.perform_async(build_reject_json(follow), follow.target_account_id, follow.account.inbox_url)
  end

  def build_json(follow)
    Oj.dump(serialize_payload(follow, ActivityPub::UndoFollowSerializer))
  end

  def build_reject_json(follow)
    Oj.dump(serialize_payload(follow, ActivityPub::RejectFollowSerializer))
  end
end
