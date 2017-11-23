# frozen_string_literal: true
require 'sidekiq-scheduler'

class Scheduler::DeadRecordsCleanupScheduler
  include Sidekiq::Worker

  DATA_RETENTION = 30.days

  def perform
    Status.only_deleted.where('deleted_at < ?', DATA_RETENTION.ago).reorder(nil).in_batches.destroy_all
  end
end
