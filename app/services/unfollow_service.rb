# frozen_string_literal: true

class UnfollowService < BaseService
  include Payloadable
  include Redisable
  include Lockable

  # Unfollow and notify the remote user
  # @param [Account] follower Where to unfollow from
  # @param [Account] followee Which to unfollow
  # @param [Hash] options
  # @option [Boolean] :skip_unmerge
  def call(follower, followee, options = {})
    @follower = follower
    @followee = followee
    @options  = options

    with_redis_lock("relationship:#{[follower.id, followee.id].sort.join(':')}") do
      unfollow! || undo_follow_request!
    end
  end

  private

  def unfollow!
    follow = Follow.find_by(account: @follower, target_account: @followee)
    return unless follow

    # List members are removed immediately with the follow relationship removal,
    # so we need to fetch the list IDs first
    list_ids = @follower.owned_lists.with_list_account(@followee).pluck(:list_id) unless @options[:skip_unmerge]

    follow.destroy!

    if @followee.local? && @follower.remote? && @follower.activitypub?
      send_reject_follow(follow)
    elsif @followee.remote? && @followee.activitypub?
      send_undo_follow(follow)
    end

    unless @options[:skip_unmerge]
      UnmergeWorker.perform_async(@followee.id, @follower.id, 'home')
      UnmergeWorker.push_bulk(list_ids) do |list_id|
        [@followee.id, list_id, 'list']
      end
    end

    follow
  end

  def undo_follow_request!
    follow_request = FollowRequest.find_by(account: @follower, target_account: @followee)
    return unless follow_request

    follow_request.destroy!

    send_undo_follow(follow_request) unless @followee.local?

    follow_request
  end

  def send_undo_follow(follow)
    ActivityPub::DeliveryWorker.perform_async(build_json(follow), follow.account_id, follow.target_account.inbox_url)
  end

  def send_reject_follow(follow)
    ActivityPub::DeliveryWorker.perform_async(build_reject_json(follow), follow.target_account_id, follow.account.inbox_url)
  end

  def build_json(follow)
    serialize_payload(follow, ActivityPub::UndoFollowSerializer).to_json
  end

  def build_reject_json(follow)
    serialize_payload(follow, ActivityPub::RejectFollowSerializer).to_json
  end
end
