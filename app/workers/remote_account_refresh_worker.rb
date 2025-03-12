# frozen_string_literal: true

class RemoteAccountRefreshWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 3

  def perform(id)
    account = Account.remote.find_by(id: id)
    return if account.nil?

    ActivityPub::FetchRemoteAccountService.new.call(account.uri)
  rescue Mastodon::UnexpectedResponseError => e
    raise e unless response_error_unsalvageable?(e.response)
  end
end
