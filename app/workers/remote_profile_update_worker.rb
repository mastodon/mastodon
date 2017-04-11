# frozen_string_literal: true

class RemoteProfileUpdateWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id, body, resubscribe)
    UpdateRemoteProfileService.new.call(body, Account.find(account_id), resubscribe)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
