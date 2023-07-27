# frozen_string_literal: true

class Scheduler::InstanceRefreshScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    Instance.refresh
    InstancesIndex.import if Chewy.enabled?
  end
end
