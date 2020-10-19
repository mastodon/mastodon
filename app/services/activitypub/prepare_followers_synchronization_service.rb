# frozen_string_literal: true

class ActivityPub::PrepareFollowersSynchronizationService < BaseService
  include JsonLdHelper

  def call(account, params)
    @account = account

    return unless params['collectionId'] == @account.followers_url
    return if invalid_origin?(params['url'])
    return if @account.followers_hash('local') == params['digest']

    ActivityPub::FollowersSynchronizationWorker.perform_async(@account.id, params['url'])
  end
end
