# frozen_string_literal: true

module Vacuum
  class PreviewCardsVacuum < Vacuum::RetentionPeriod
    TTL = 1.day.freeze

    def perform
      vacuum_cached_images! if @retention_period.present?
    end

    private

    def vacuum_cached_images!
      PreviewCard.cached.where(updated_at: ...@retention_period.ago)
                 .find_each(&:destroy_image!)
    end
  end
end
