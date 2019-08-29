# frozen_string_literal: true

class RemovalWorker
  include Sidekiq::Worker

  def perform(status_id, options = {})
    RemoveStatusService.new.call(Status.with_discarded.find(status_id), **options.symbolize_keys)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
