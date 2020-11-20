# frozen_string_literal: true

class AccountDeletionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id, options = {})
    reserve_username = options.with_indifferent_access.fetch(:reserve_username, true)
    skip_activitypub = options.with_indifferent_access.fetch(:skip_activitypub, false)
    DeleteAccountService.new.call(Account.find(account_id), reserve_username: reserve_username, skip_activitypub: skip_activitypub, reserve_email: false)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
