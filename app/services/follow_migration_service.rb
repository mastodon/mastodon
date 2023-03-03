# frozen_string_literal: true

class FollowMigrationService < FollowService
  # Follow an account with the same settings as another account, and unfollow the old account once the request is sent
  # @param [Account] source_account From which to follow
  # @param [Account] target_account Account to follow
  # @param [Account] old_target_account Account to unfollow once the follow request has been sent to the new one
  # @option [Boolean] bypass_locked Whether to immediately follow the new account even if it is locked
  def call(source_account, target_account, old_target_account, bypass_locked: false)
    @old_target_account = old_target_account

    follow    = source_account.active_relationships.find_by(target_account: old_target_account)
    reblogs   = follow&.show_reblogs?
    notify    = follow&.notify?

    super(source_account, target_account, reblogs: reblogs, notify: notify, bypass_locked: bypass_locked, bypass_limit: true)
  end

  private

  def request_follow!
    follow_request = @source_account.request_follow!(@target_account, **follow_options.merge(rate_limit: @options[:with_rate_limit], bypass_limit: @options[:bypass_limit]))

    if @target_account.local?
      LocalNotificationWorker.perform_async(@target_account.id, follow_request.id, follow_request.class.name, 'follow_request')
      UnfollowService.new.call(@source_account, @old_target_account, skip_unmerge: true)
    elsif @target_account.activitypub?
      ActivityPub::MigratedFollowDeliveryWorker.perform_async(build_json(follow_request), @source_account.id, @target_account.inbox_url, @old_target_account.id)
    end

    follow_request
  end

  def direct_follow!
    follow = super
    UnfollowService.new.call(@source_account, @old_target_account, skip_unmerge: true)
    follow
  end

  def follow_options
    @options.slice(:reblogs, :notify)
  end
end
