# frozen_string_literal: true

class DistributionWorker
  include Sidekiq::Worker
  include Redisable
  include Lockable

  def perform(status_id, options = {})
    #note: add log here to print options to see what options are passed by default
    with_lock("distribute:#{status_id}") do
      FanOutOnWriteService.new.call(Status.find(status_id), **options.symbolize_keys)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
