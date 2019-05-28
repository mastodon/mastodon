# frozen_string_literal: true

class Scheduler::EmailScheduler
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed, retry: 0

  FREQUENCY      = 7.days.freeze
  SIGN_IN_OFFSET = 1.day.freeze

  def perform
    eligible_users.reorder(nil).find_each do |user|
      next unless user.allows_digest_emails?
      DigestMailerWorker.perform_async(user.id)
    end
  end

  private

  def eligible_users
    User.emailable
        .where('current_sign_in_at < ?', (FREQUENCY + SIGN_IN_OFFSET).ago)
        .where('last_emailed_at IS NULL OR last_emailed_at < ?', FREQUENCY.ago)
  end
end
