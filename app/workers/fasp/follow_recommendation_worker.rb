# frozen_string_literal: true

class Fasp::FollowRecommendationWorker < Fasp::BaseWorker
  sidekiq_options retry: 0

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
      with_provider(provider) do
        Fasp::Request.new(provider).get("/follow_recommendation/v0/accounts?#{params}").each do |uri|
          next if Account.where(uri:).any?

          new_account = fetch_service.call(uri)

          if new_account.present?
            Fasp::FollowRecommendation.find_or_create_by(requesting_account: account, recommended_account: new_account)
            async_refresh.increment_result_count(by: 1)
          end
        end
      end
    end

    # Invalidate follow recommendation cache so it does not
    # take up to 15 minutes for the new recommendations to
    # show up
    Rails.cache.delete("follow_recommendations/#{account.id}")
  rescue ActiveRecord::RecordNotFound
    # Nothing to be done
  ensure
    async_refresh.finish!
  end
end
