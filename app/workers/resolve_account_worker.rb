# frozen_string_literal: true

class ResolveAccountWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', lock: :until_executed

  def perform(uri)
    ResolveAccountService.new.call(uri)
  end
end
