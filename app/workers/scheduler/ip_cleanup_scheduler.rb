# frozen_string_literal: true
require 'sidekiq-scheduler'

class Scheduler::IpCleanupScheduler
  include Sidekiq::Worker

  def perform
    time_ago = 5.years.ago
    SessionActivation.where('updated_at < ?', time_ago).destroy_all
    User.where('last_sign_in_at < ?', time_ago).update_all(last_sign_in_ip: nil)
  end
end
