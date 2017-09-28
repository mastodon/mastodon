# frozen_string_literal: true

class ResolveRemoteAccountWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', unique: :until_executed

  def perform(uri)
    ResolveRemoteAccountService.new.call(uri)
  end
end
