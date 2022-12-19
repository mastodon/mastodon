class Scheduler::InstanceRefreshScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    Instance.refresh
  end
end
