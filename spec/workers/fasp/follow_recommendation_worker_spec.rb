# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fasp::FollowRecommendationWorker, feature: :fasp do
  include ProviderRequestHelper

  let(:provider) { Fabricate(:follow_recommendation_fasp) }
  let(:account) { Fabricate(:account) }
  let(:fetch_service) { instance_double(ActivityPub::FetchRemoteActorService, call: true) }

  let!(:stubbed_request) do
    account_uri = ActivityPub::TagManager.instance.uri_for(account)
    path = "/follow_recommendation/v0/accounts?accountUri=#{URI.encode_uri_component(account_uri)}"
    stub_provider_request(provider,
                          method: :get,
                          path:,
                          response_body: [
                            'https://fedi.example.com/accounts/1',
                            'https://fedi.example.com/accounts/7',
                          ])
  end

  before do
    allow(ActivityPub::FetchRemoteActorService).to receive(:new).and_return(fetch_service)
  end

  it "sends the requesting account's uri to provider and fetches received account uris" do
    described_class.new.perform(account.id)

    expect(stubbed_request).to have_been_made
    expect(fetch_service).to have_received(:call).with('https://fedi.example.com/accounts/1')
    expect(fetch_service).to have_received(:call).with('https://fedi.example.com/accounts/7')
  end

  it 'marks a running async refresh as finished' do
    async_refresh = AsyncRefresh.create("fasp:follow_recommendation:#{account.id}", count_results: true)

    described_class.new.perform(account.id)

    expect(async_refresh.reload).to be_finished
  end

  it 'tracks the number of fetched accounts in the async refresh' do
    async_refresh = AsyncRefresh.create("fasp:follow_recommendation:#{account.id}", count_results: true)

    described_class.new.perform(account.id)

    expect(async_refresh.reload.result_count).to eq 2
  end
end
