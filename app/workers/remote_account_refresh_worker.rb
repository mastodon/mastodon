# frozen_string_literal: true

class RemoteAccountRefreshWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 3

  def perform(id)
    account = Account.find_by(id: id)
    return if account.nil? || account.local?

    account_json = fetch_resource(account.uri, true)

    fetched_account = ActivityPub::FetchRemoteAccountService.new.call(account.uri, prefetched_body: account_json)
    ActivityPub::AccountBackfillService.new.call(account, prefetched_body: account_json)
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
