# frozen_string_literal: true

class RemoteAccountRefreshWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 3

  def perform(id)
    account = Account.find_by(id: id)
    return if account.nil? || account.local?

    ActivityPub::FetchRemoteAccountService.new.call(account.uri)
  rescue Mastodon::UnexpectedResponseError => e
    response = e.response

    raise(e) unless response_error_unsalvageable?(response)
  end
end
