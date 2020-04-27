# frozen_string_literal: true

class Scheduler::MediaCleanupScheduler
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, retry: 0

  def perform
    unattached_media.find_each(&:destroy)
  end

  private

  def unattached_media
    MediaAttachment.reorder(nil).unattached.where('created_at < ?', 1.day.ago)
  end
end
