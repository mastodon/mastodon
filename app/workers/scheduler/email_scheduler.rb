# frozen_string_literal: true

class Scheduler::EmailScheduler
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed, retry: 0

  def perform
    eligible_users.reorder(nil).find_each do |user|
      next unless user.allows_digest_emails?
      DigestMailerWorker.perform_async(user.id)
    end
  end

  private

  def eligible_users
    User.confirmed
        .joins(:account)
        .where(accounts: { silenced: false, suspended: false })
        .where(disabled: false)
        .where('current_sign_in_at < ?', 20.days.ago)
        .where('last_emailed_at IS NULL OR last_emailed_at < ?', 20.days.ago)
  end
end
