# frozen_string_literal: true

class Scheduler::AutoCloseRegistrationsScheduler
  include Sidekiq::Worker
  include Redisable

  sidekiq_options retry: 0

  # Automatically switch away from open registrations if no
  # moderator had any activity in that period of time
  OPEN_REGISTRATIONS_MODERATOR_THRESHOLD = 1.week + UserTrackingConcern::SIGN_IN_UPDATE_FREQUENCY

  def perform
    return if Rails.configuration.x.email_domains_whitelist.present? || ENV['DISABLE_AUTOMATIC_SWITCHING_TO_APPROVED_REGISTRATIONS'] == 'true'
    return unless Setting.registrations_mode == 'open'

    Setting.registrations_mode = 'approved' unless active_moderators?
  end

  private

  def active_moderators?
    User.those_who_can(:manage_reports).exists?(current_sign_in_at: OPEN_REGISTRATIONS_MODERATOR_THRESHOLD.ago...)
  end
end
