# frozen_string_literal: true

class Scheduler::EmailScheduler
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed, retry: 0

  FREQUENCY      = 1.day.freeze
  SIGN_IN_OFFSET = 1.day.freeze

  def perform
    eligible_users.reorder(nil).find_each do |user|
      DigestMailerWorker.perform_async(user.id) if user.allows_digest_emails?
    end
  end

  private

  def eligible_users
    User.emailable
        .where('current_sign_in_at < ?', (FREQUENCY + SIGN_IN_OFFSET).ago)
        .where('last_emailed_at IS NULL OR last_emailed_at < ?', FREQUENCY.ago)
  end
end
