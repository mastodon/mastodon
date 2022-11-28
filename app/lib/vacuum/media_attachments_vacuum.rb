# frozen_string_literal: true

module Vacuum
  class MediaAttachmentsVacuum < Vacuum::RetentionPeriod
    TTL = 1.day.freeze

    def perform
      vacuum_orphaned_records!
      vacuum_cached_files! if @retention_period.present?
    end

    private

    def vacuum_cached_files!
      MediaAttachment.unscoped
                     .past_retention(@retention_period.ago)
                     .find_each(&:destroy_file_and_thumbnail!)
    end

    def vacuum_orphaned_records!
      MediaAttachment.unscoped.orphaned(TTL.ago).in_batches(&:destroy_all)
    end
  end
end
