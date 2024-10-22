# frozen_string_literal: true

class RemoteAccountRefreshWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 3

  def perform(id)
    account = Account.find_by(id: id)
    return if account.nil? || account.local?

    fetched_account = ActivityPub::FetchRemoteAccountService.new.call(account.uri)
    ActivityPub::AccountBackfillService.new.call(fetched_account.is_a?(Account) ? fetched_account : account)
    fetched_account
  rescue Mastodon::UnexpectedResponseError => e
    response = e.response

    if response_error_unsalvageable?(response)
      # Give up
    else
      raise e
    end
  end
end
