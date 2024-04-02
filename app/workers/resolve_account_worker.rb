# frozen_string_literal: true

class ResolveAccountWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', lock: :until_executed, lock_ttl: 1.day.to_i

  def perform(uri)
    ResolveAccountService.new.call(uri)
  end
end
