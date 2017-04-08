# frozen_string_literal: true

class DistributionWorker < ApplicationWorker
  include Sidekiq::Worker

  def perform(status_id)
    FanOutOnWriteService.new.call(Status.find(status_id))
  rescue ActiveRecord::RecordNotFound
    info("Couldn't find the status")
  end
end
