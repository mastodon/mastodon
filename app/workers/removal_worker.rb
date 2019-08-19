# frozen_string_literal: true

class RemovalWorker
  include Sidekiq::Worker

  def perform(status_id)
    RemoveStatusService.new.call(Status.with_discarded.find(status_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
