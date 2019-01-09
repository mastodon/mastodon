# frozen_string_literal: true

class Scheduler::ScheduledStatusesScheduler
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed, retry: 0

  def perform
    due_statuses.find_each do |scheduled_status|
      PublishScheduledStatusWorker.perform_at(scheduled_status.scheduled_at, scheduled_status.id)
    end
  end

  private

  def due_statuses
    ScheduledStatus.where('scheduled_at <= ?', Time.now.utc + PostStatusService::MIN_SCHEDULE_OFFSET)
  end
end
