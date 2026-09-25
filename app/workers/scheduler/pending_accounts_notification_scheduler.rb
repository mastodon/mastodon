# frozen_string_literal: true

class Scheduler::PendingAccountsNotificationScheduler
  include Sidekiq::Worker
  include Redisable

  sidekiq_options retry: 0

  def perform
    last_user_id = redis.get('pending_accounts_notification_scheduler:last_user_id').presence || 0

    # Only check accounts that have not generated a confirmation e-mail, as those will use the regular flow.
    scope = User.pending.where(confirmation_sent_at: nil).includes(:account, :invite_request)
    users = scope.where(id: last_user_id...).order(id: :asc).to_a

    notify_staff_about_pending_accounts!(users.map(&:account)) unless users.empty?

    redis.set('pending_accounts_notification_scheduler:last_user_id', users.last&.id || last_user_id, ex: 1.week)
  end

  private

  def notify_staff_about_pending_accounts!(accounts)
    User.those_who_can(:manage_users).includes(:account).find_each do |u|
      next unless u.allows_pending_account_emails?

      AdminMailer.with(recipient: u.account).new_pending_accounts(accounts).deliver_later
    end
  end
end
