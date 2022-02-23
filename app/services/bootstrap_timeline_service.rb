# frozen_string_literal: true

class BootstrapTimelineService < BaseService
  def call(source_account)
    @source_account = source_account

    autofollow_inviter!
    notify_staff!
  end

  private

  def autofollow_inviter!
    return unless @source_account&.user&.invite&.autofollow?

    FollowService.new.call(@source_account, @source_account.user.invite.user.account)
  end

  def notify_staff!
    User.staff.includes(:account).find_each do |user|
      NotifyService.new.call(user.account, :'admin.sign_up', @source_account)
    end
  end
end
