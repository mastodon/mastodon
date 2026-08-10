# frozen_string_literal: true

class Scheduler::ModerationListSynchronizationScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 6.hours.to_i

  def perform
    return unless update_lists!

    ProcessModerationListsService.new.call

    # TODO: mail suggestions
  end

  private

  def update_lists!
    ModerationSubscription.to_a.any? do |subscription|
      ModerationSubscriptionSyncService.new.call(subscription)
    end
  end
end
