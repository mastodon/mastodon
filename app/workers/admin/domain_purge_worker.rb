# frozen_string_literal: true

class Admin::DomainPurgeWorker
  include Sidekiq::Worker

  def perform(domain)
    PurgeDomainService.new.call(domain)
  end
end
