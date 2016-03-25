class DistributionWorker
  include Sidekiq::Worker

  def perform(status_id)
    FanOutOnWriteService.new.(Status.find(status_id))
  end
end
