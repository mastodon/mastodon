# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fasp::AccountSearchWorker, feature: :fasp do
  include ProviderRequestHelper

  subject { described_class.new.perform('cats') }

  let(:provider) { Fabricate(:account_search_fasp) }
  let(:account) { Fabricate(:account) }
  let(:fetch_service) { instance_double(ActivityPub::FetchRemoteActorService, call: true) }
  let(:path) { '/account_search/v0/search?term=cats&limit=10' }

  let!(:stubbed_request) do
    stub_provider_request(provider,
                          method: :get,
                          path:,
                          response_body: [
                            'https://fedi.example.com/accounts/2',
                            'https://fedi.example.com/accounts/9',
                          ])
  end

  before do
    allow(ActivityPub::FetchRemoteActorService).to receive(:new).and_return(fetch_service)
  end

  it 'requests search results and fetches received account uris' do
    subject

    expect(stubbed_request).to have_been_made
    expect(fetch_service).to have_received(:call).with('https://fedi.example.com/accounts/2')
    expect(fetch_service).to have_received(:call).with('https://fedi.example.com/accounts/9')
  end

  it 'marks a running async refresh as finished' do
    async_refresh = AsyncRefresh.create("fasp:account_search:#{Digest::MD5.base64digest('cats')}", count_results: true)

    subject

    expect(async_refresh.reload).to be_finished
  end

  it 'tracks the number of fetched accounts in the async refresh' do
    async_refresh = AsyncRefresh.create("fasp:account_search:#{Digest::MD5.base64digest('cats')}", count_results: true)

    subject

    expect(async_refresh.reload.result_count).to eq 2
  end

  describe 'provider delivery failure handling' do
    let(:base_stubbed_request) do
      stub_request(:get, provider.url(path))
    end

    it_behaves_like('worker handling fasp delivery failures')
  end
end
