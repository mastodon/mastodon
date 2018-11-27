# frozen_string_literal: true

class Scheduler::DeletionScheduler
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed, retry: 0

  def perform
    DeletionSchedule.includes(:user).find_in_batches do |schedules|
      DeletionScheduleWorker.push_bulk(schedules) do |schedule|
        [schedule.user.account_id, schedule.delay]
      end
    end
  end
end
