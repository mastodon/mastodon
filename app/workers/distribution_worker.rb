# frozen_string_literal: true

class DistributionWorker < ApplicationWorker
  include Sidekiq::Worker

  def perform(status_id)
    status = Status.find(status_id)

    FanOutOnWriteService.new.call(status)
    WarmCacheService.new.call(status)
  rescue ActiveRecord::RecordNotFound
    info("Couldn't find the status")
  end
end
