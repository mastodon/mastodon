# frozen_string_literal: true

class Scheduler::UserRegistrationProtectionScheduler
  include Sidekiq::Worker

  def perform
    return unless User.where(created_at: (Time.now.utc - 5.minutes)..Time.now.utc).count > ENV.fetch('MAX_REGISTRATIONS_THRESHOLD', 1_000).to_i

    Setting.registrations_mode = if Setting.registrations_mode == 'open'
                                   'approved'
                                 else
                                   'none'
                                 end
  end
end
