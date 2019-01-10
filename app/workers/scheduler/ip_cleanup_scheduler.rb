# frozen_string_literal: true

class Scheduler::IpCleanupScheduler
  include Sidekiq::Worker

  RETENTION_PERIOD = 1.year

  sidekiq_options unique: :until_executed, retry: 0

  def perform
    time_ago = RETENTION_PERIOD.ago
    SessionActivation.where('updated_at < ?', time_ago).destroy_all
    User.where('last_sign_in_at < ?', time_ago).update_all(last_sign_in_ip: nil)
  end
end
