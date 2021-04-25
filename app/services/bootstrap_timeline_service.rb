# frozen_string_literal: true

class BootstrapTimelineService < BaseService
  def call(source_account)
    @source_account = source_account

    autofollow_inviter!
    notify_staff!
    autofollow_bootstrap_timeline_accounts! if Setting.enable_auto_follow_bootstrap_timeline_accounts
  end

  private

  def autofollow_inviter!
    return unless @source_account&.user&.invite&.autofollow?

    FollowService.new.call(@source_account, @source_account.user.invite.user.account)
  end

  def notify_staff!
    User.staff.includes(:account).find_each do |user|
      LocalNotificationWorker.perform_async(user.account_id, @source_account.id, 'Account', 'admin.sign_up')
    end
  end
  
  def autofollow_bootstrap_timeline_accounts!
    auto_follow_bootstrap_timeline_accounts.each do |target_account|
      begin
        FollowService.new.call(@source_account, target_account)
      rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
        nil
      end
    end
  end

  def auto_follow_bootstrap_timeline_accounts
    return @auto_follow_bootstrap_timeline_accounts if defined?(@auto_follow_bootstrap_timeline_accounts)

    @auto_follow_bootstrap_timeline_accounts = auto_follow_bootstrap_timeline_accounts_usernames.empty? ? admin_accounts : local_unlocked_accounts(auto_follow_bootstrap_timeline_accounts_usernames)
  end

  def auto_follow_bootstrap_timeline_accounts_usernames
    @auto_follow_bootstrap_timeline_accounts_usernames ||= (Setting.auto_follow_bootstrap_timeline_accounts || '').split(',').map { |str| str.strip.gsub(/\A@/, '') }.reject(&:blank?)
  end

  def admin_accounts
    User.admins
        .includes(:account)
        .where(accounts: { locked: false })
        .map(&:account)
  end

  def local_unlocked_accounts(usernames)
    Account.local
           .without_suspended
           .where(username: usernames)
           .where(locked: false)
           .where(moved_to_account_id: nil)
    FollowService.new.call(@source_account, @source_account.user.invite.user.account)
  end
end
