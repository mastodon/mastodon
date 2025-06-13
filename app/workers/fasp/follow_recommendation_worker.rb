# frozen_string_literal: true

class Fasp::FollowRecommendationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'fasp', retry: 0

  def perform(account_id)
    return unless Mastodon::Feature.fasp_enabled?

    async_refresh = AsyncRefresh.new("fasp:follow_recommendation:#{account_id}")

    account = Account.find(account_id)

    follow_recommendation_providers = Fasp::Provider.with_capability('follow_recommendation')
    return if follow_recommendation_providers.none?

    account_uri = ActivityPub::TagManager.instance.uri_for(account)
    params = { accountUri: account_uri }.to_query
    fetch_service = ActivityPub::FetchRemoteActorService.new

    follow_recommendation_providers.each do |provider|
      Fasp::Request.new(provider).get("/follow_recommendation/v0/accounts?#{params}").each do |uri|
        next if Account.where(uri:).any?

        account = fetch_service.call(uri)
        async_refresh.increment_result_count(by: 1) if account.present?
      end
    end
  rescue ActiveRecord::RecordNotFound
    # Nothing to be done
  ensure
    async_refresh.finish!
  end
end
