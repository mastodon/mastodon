class ProcessingWorker
  include Sidekiq::Worker

  def perform(account_id, body)
    ProcessFeedService.new.call(body, Account.find(account_id))
  end
end
