class AfterUnallowDomainWorker
  include Sidekiq::Worker

  def perform(domain)
    AfterUnallowDomainService.new.call(domain)
  end
end
