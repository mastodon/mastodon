# frozen_string_literal: true

class RemoteProfileUpdateWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id, body, resubscribe); end
end
