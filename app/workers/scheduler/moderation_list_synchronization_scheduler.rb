# frozen_string_literal: true

class Scheduler::ModerationListSynchronizationScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 6.hours.to_i

  def perform
    return unless update_lists!

    ProcessModerationListsService.new.call

    mail_suggestions!
  end

  private

  def update_lists!
    ModerationSubscription.all.map do |subscription|
      ModerationSubscriptionSyncService.new.call(subscription)
    end.any?
  end

  def mail_suggestions!
    return unless ModerationSuggestion.exists?(state: :new)

    User.those_who_can(:manage_federation).includes(:account).find_each do |user|
      next unless user.settings['notification_emails.moderation_suggestions']

      AdminMailer.with(recipient: user.account).new_moderation_suggestions.deliver_later
    end

    ModerationSuggestion.where(state: :new).in_batches.update_all(state: :mailed)
  end
end
