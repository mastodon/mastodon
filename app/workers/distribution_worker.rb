# frozen_string_literal: true

class DistributionWorker
  include Sidekiq::Worker

  sidekiq_options dead: false

  def perform(status_id)
    FanOutOnWriteService.new.call(Status.find(status_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
