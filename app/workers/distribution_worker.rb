# frozen_string_literal: true

class DistributionWorker
  include Sidekiq::Worker

  def perform(status_id)
    status = Status.find(status_id)

    FanOutOnWriteService.new.call(status)
    WarmCacheService.new.call(status)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
