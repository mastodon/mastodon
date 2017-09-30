# frozen_string_literal: true

class DistributionWorker
  include Sidekiq::Worker

  def perform(status_id)
    FanOutOnWriteService.new.call(Status.find(status_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
