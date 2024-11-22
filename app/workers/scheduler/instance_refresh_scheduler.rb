# frozen_string_literal: true

class Scheduler::InstanceRefreshScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform
    Instance.refresh
    InstancesIndex.import if Chewy.enabled?
  end
end
