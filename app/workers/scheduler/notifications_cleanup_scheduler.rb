# frozen_string_literal: true

class Scheduler::NotificationsCleanupScheduler
  include Sidekiq::Worker
  include LowPriorityScheduler

  TYPES_TO_CLEAN_UP = Notification::TYPES

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform
    return if under_load?

    TYPES_TO_CLEAN_UP.each do |type|
      NotificationsCleanupService.new.call(type)
    end
  end
end
