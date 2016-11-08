class RegenerationWorker
  include Sidekiq::Worker

  def perform(account_id, timeline_type)
    PrecomputeFeedService.new.call(timeline_type, Account.find(account_id))
  end
end
