# frozen_string_literal: true

class ActivityPub::PrepareFollowersSynchronizationService < BaseService
  include JsonLdHelper

  def call(account, params)
    @account = account

    return if params['collectionId'] != @account.followers_url || non_matching_uri_hosts?(@account.uri, params['url']) || @account.local_followers_hash == params['digest']

    ActivityPub::FollowersSynchronizationWorker.perform_async(@account.id, params['url'])
  end
end
