# frozen_string_literal: true

class BootstrapTimelineService < BaseService
  def call(source_account)
    @source_account = source_account

    autofollow_inviter!
    autofollow_bootstrap_timeline_accounts!
  end

  private

  def autofollow_inviter!
    return unless @source_account&.user&.invite&.autofollow?
    FollowService.new.call(@source_account, @source_account.user.invite.user.account)
  end

  def autofollow_bootstrap_timeline_accounts!
    bootstrap_timeline_accounts.each do |target_account|
      FollowService.new.call(@source_account, target_account)
    end
  end

  def bootstrap_timeline_accounts
    return @bootstrap_timeline_accounts if defined?(@bootstrap_timeline_accounts)

    @bootstrap_timeline_accounts = bootstrap_timeline_accounts_usernames.empty? ? admin_accounts : local_unlocked_accounts(bootstrap_timeline_accounts_usernames)
  end

  def bootstrap_timeline_accounts_usernames
    @bootstrap_timeline_accounts_usernames ||= (Setting.bootstrap_timeline_accounts || '').split(',').map { |str| str.strip.gsub(/\A@/, '') }.reject(&:blank?)
  end

  def admin_accounts
    User.admins
        .includes(:account)
        .where(accounts: { locked: false })
        .map(&:account)
  end

  def local_unlocked_accounts(usernames)
    Account.local
           .where(username: usernames)
           .where(locked: false)
  end
end
