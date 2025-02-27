# frozen_string_literal: true

class Fasp::AccountSearchWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'fasp', retry: 0

  def perform(query)
    return unless Mastodon::Feature.fasp_enabled?

    account_search_providers = Fasp::Provider.with_capability('account_search')
    return if account_search_providers.none?

    params = { term: query, limit: 10 }.to_query
    fetch_service = ActivityPub::FetchRemoteActorService.new

    account_search_providers.each do |provider|
      Fasp::Request.new(provider).get("/account_search/v0/search?#{params}").each do |uri|
        next if Account.where(uri:).any?

        fetch_service.call(uri)
      end
    end
  end
end
