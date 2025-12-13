# frozen_string_literal: true

class Fasp::AccountSearchWorker < Fasp::BaseWorker
  sidekiq_options retry: 0

  def perform(query)
    return unless Mastodon::Feature.fasp_enabled?

    async_refresh = AsyncRefresh.new("fasp:account_search:#{Digest::MD5.base64digest(query)}")

    account_search_providers = Fasp::Provider.with_capability('account_search')
    return if account_search_providers.none?

    params = { term: query, limit: 10 }.to_query
    fetch_service = ActivityPub::FetchRemoteActorService.new

    account_search_providers.each do |provider|
      with_provider(provider) do
        Fasp::Request.new(provider).get("/account_search/v0/search?#{params}").each do |uri|
          next if Account.where(uri:).any?

          account = fetch_service.call(uri)
          async_refresh.increment_result_count(by: 1) if account.present?
        end
      end
    end
  ensure
    async_refresh&.finish!
  end
end
