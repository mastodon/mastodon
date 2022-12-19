class Admin::DomainPurgeWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', lock: :until_executed

  def perform(domain)
    PurgeDomainService.new.call(domain)
  end
end
